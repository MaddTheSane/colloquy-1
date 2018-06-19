//
//  JVStandardCommands.swift
//  Colloquy (Old)
//
//  Created by C.W. Betts on 1/27/16.
//
//

import Foundation
import ChatCore
import WebKit

public class StandardCommands : NSObject, MVChatPluginCommandSupport, MVChatPlugin {
	public required init(manager: MVChatPluginManager) {
		super.init()
	}
	
	private func handleFileSend(arguments: String!, for connection: MVChatConnection!) -> Bool {
		var to: NSString?
		var path: NSString?
		let passive = UserDefaults.standard.bool(forKey: "JVSendFilesPassively")
		let scanner = Scanner(string: arguments)
		scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: nil)
		scanner.scanCharacters(from: CharacterSet.whitespacesAndNewlines, into: nil)
		scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &to)
		scanner.scanCharacters(from: CharacterSet.whitespacesAndNewlines, into: nil)
		scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "\n\r"), into: &path)
		guard let to2 = to as String?, to2.count > 0 else {
			return false
		}
		var directory: ObjCBool = false
		path = path?.standardizingPath as NSString?
		if let path = path as String?, path.count > 0 && !FileManager.default.fileExists(atPath: path, isDirectory: &directory) {
			return true
		}
		if directory.boolValue {
			return true
		}
		
		let user = connection.chatUsers(withNickname: to2).first
		
		if let path = path as String?, path.count > 0 {
			NotificationCenter.chat.post(name: NSNotification.Name.MVFileTransferStarted, object: user?.sendFile(path, passively: passive))
		} else {
			user?.sendFile(nil)
		}
		return true
	}
	
	private func handleCTCP(arguments: String, for connection: MVChatConnection!) -> Bool {
		var to: NSString?, ctcpRequest: NSString?, ctcpArgs: NSString?
		let scanner = Scanner(string: arguments)
		
		scanner.scanUpToCharacters(from: CharacterSet.whitespaces, into: &to)
		scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &ctcpRequest)
		scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "\n\r"), into: &ctcpArgs)
		
		guard let to2 = to as String?, let ctcpRequest2 = ctcpRequest as String?, to2.count != 0 && ctcpRequest2.count != 0 else {
			return false
		}
		if to == nil || to!.length == 0 || ctcpRequest == nil || ctcpRequest!.length == 0 {
			return false;
		}
		
		let user = connection.chatUsers(withNickname: to2).first
		
		user?.sendSubcodeRequest(ctcpRequest2, withArguments: ctcpArgs)
		return true;
	}
	
	private func handleServerConnect(arguments: String!) -> Bool {
		if let _ = arguments?.range(of: "://"), let url = URL(string: arguments) {
			MVConnectionsController.default.handle(url, andConnectIfPossible: true)
		} else if let arguments = arguments, arguments.count > 0 {
			var address: NSString?
			var port: Int32 = 0
			let scanner = Scanner(string: arguments)
			scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &address)
			scanner.scanInt32(&port)
			var url: URL?
			
			if let address = address as String? {
				if port != 0 {
					url = URL(string: "irc://\(address.encodingIllegalURLCharacters ?? ""):\(port)")
				} else {
					url = URL(string: "irc://\(address.encodingIllegalURLCharacters ?? "")")
				}
			} else {
				MVConnectionsController.default.newConnection(nil)
			}
			
			if let url = url {
				MVConnectionsController.default.handle(url, andConnectIfPossible: true)
			}
		} else {
			MVConnectionsController.default.newConnection(nil)
		}
		return true
	}
	
	private func handleJoin(arguments: String!, for connection: MVChatConnection!) -> Bool {
		let channels = arguments.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: ",")
		if channels.count == 1 {
			connection.joinChatRoomNamed(arguments.trimmingCharacters(in: CharacterSet.whitespaces))
			return true
		} else if channels.count > 1 {
			var channels1 = channels.map({ return $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}).filter({ return $0.count != 0})
			channels1 += channels
			connection.joinChatRoomsNamed(channels1)
			return true
		} else {
			let browser = JVChatRoomBrowser(for: connection)
			browser?.showWindow(nil)
			browser?.show(nil)
			return true
		}
	}
	
	private func handlePart(arguments: String!, for connection: MVChatConnection!) -> Bool {
		let args = arguments.components(separatedBy: " ")
		let channels = args[0].components(separatedBy: ",")
		
		let message = args[1..<args.endIndex].joined(separator: " ")
		let reason = NSAttributedString(string: message)
		
		if channels.count == 1 {
			connection.joinedChatRoom(withName: channels[0])?.part(withReason: reason)
			return true;
		} else if channels.count > 1 {
			for channel in channels {
				let channel1 = channel.trimmingCharacters(in: CharacterSet.whitespaces)
				if channel1.count != 0 {
					connection.joinedChatRoom(withName: channel1)?.part(withReason: reason)
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	private func handleMessage(command: String!, with message: NSAttributedString!, for connection: MVChatConnection!, alwaysShow always: Bool = true) -> Bool {
		var to1: NSString?
		var msg: NSAttributedString?
		let scanner = Scanner(string: message.string)
		
		scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &to1)
		
		guard let to = to1, to.length > 0 else {
			return false
		}
		
		if message.length >= scanner.scanLocation + 1 {
			scanner.scanLocation += 1
			msg = message.attributedSubstring(from: NSMakeRange(scanner.scanLocation, message.length - scanner.scanLocation))
		}
		
		var show = false
		show = ( command.caseInsensitiveCompare("query") == .orderedSame ? true : show )
		if let msg = msg, msg.length > 0 {
			show = true
		}
		show = ( always ? true : show );
		var chatView: JVDirectChatPanel? = nil

		// this is an IRC specific command for sending to room operators only.
		if connection.type == .ircType {
			let scanner = Scanner(string: to as String);
			scanner.charactersToBeSkipped = nil;
			scanner.scanCharacters(from: connection._nicknamePrefixes, into: nil)

			if scanner.scanLocation > 0 {
				let roomTargetName = to.substring(from: scanner.scanLocation)
				if roomTargetName.count > 1 && connection.chatRoomNamePrefixes!.contains(UnicodeScalar((roomTargetName as NSString).character(at: 0))!) {
					connection.sendRawMessage(NSString(string: "PRIVMSG \(to) :\(msg?.string ?? "")"))
					
					if let room = connection.joinedChatRoom(withName: roomTargetName) as MVChatRoom? {
						chatView = JVChatController.default.chatViewController(for: room, ifExists: true)
					}
					
					let cmessage = JVMutableChatMessage(text: msg ?? "", sender: connection.localUser)
					chatView?.send(cmessage)
					chatView?.echoSentMessageToDisplay(cmessage)
					
					return true
				}
			}
		}
		
		var room: MVChatRoom?
		if command.caseInsensitiveCompare("msg") == .orderedSame && to.length > 1 && (connection.chatRoomNamePrefixes?.contains(UnicodeScalar(to.character(at: 0))!) ?? false) {
			room = connection.joinedChatRoom(withName: to as String)
			if let room = room {
				chatView = JVChatController.default.chatViewController(for: room, ifExists: true)
			}
		}
		
		var user: MVChatUser?
		if nil == chatView {
			user = connection.chatUsers(withNickname: to as String).first
			if let user = user {
				chatView = JVChatController.default.chatViewController(for: user, ifExists: !show)
			}
		}
		
		if let chatView = chatView, let msg = msg, msg.length > 0 {
			let cmessage = JVMutableChatMessage(text: msg, sender: connection.localUser)
			chatView.send(cmessage)
			chatView.addMessage(toHistory: msg)
			chatView.echoSentMessageToDisplay(cmessage)
			return true
		} else if let msg = msg, (user != nil || room != nil) && msg.length > 0 {
			let target: MVMessaging? = room ?? user
			target!.sendMessage(msg, encoding: room?.encoding ?? connection.encoding, asAction: false)
			return true
		}
		
		return false
	}
	
	private func handleMassMessage(command: String, with message: NSAttributedString!, for connection: MVChatConnection!) -> Bool {
		guard message.length > 0 else {
			return false
		}
		
		let action: Bool = {
			let cmd = command.lowercased()
			
			return cmd == "ame" || cmd == "bract"
		}()
		
		for room in (JVChatController.default.chatViewControllers(of: JVChatRoomPanel.self) as! Set<JVChatRoomPanel>) {
			let cMessage = JVMutableChatMessage(text: message, sender: room.connection?.localUser)
			cMessage.isAction = action
			room.send(cMessage)
			room.echoSentMessageToDisplay(cMessage)
		}
		
		return true
	}
	
	private func handleMassNickChange(nickname: String!) -> Bool {
		for item in MVConnectionsController.default.connectedConnections {
			item.nickname = nickname;
		}
		return true;
	}
	
	private func handleMassAway(message: NSAttributedString?) -> Bool {
		for item in MVConnectionsController.default.connectedConnections {
			item.awayStatusMessage = message;
		}
		return true;
	}
	
	private func handleIgnore(arguments args1: String, in view: JVChatViewController!) -> Bool {
		var args = args1
		// USAGE: /ignore -[p|m|n] [nickname|/regex/] ["message"|/regex/|word] [#rooms ...]
		// p makes the ignore permanent (i.e. the ignore is saved to disk)
		// m is to specify a message
		// n is to specify a nickname
		
		// EXAMPLES:
		// /ignore - will open a GUI window to add and manage ignores
		// /ignore Loser23094 - ignore Loser23094 in all rooms
		// /ignore -m "is listening" - ignore any message that has "is listening" from everyone
		// /ignore -m /is listening .*/ - ignore the message expression "is listening *" from everyone
		// /ignore -mn /eevyl.*/ /is listening .*/ #adium #colloquy #here
		// /ignore -n /bunny.*/ - ignore users whose nick starts with bunny in all rooms
		
		let argsArray = args.components(separatedBy: " ")
		var memberString = "";
		var messageString = "";
		var rooms = [String]();
		var permanent = false;
		var member = true;
		var message = false;
		var offset = 0;
		
		if args.count == 0 {
			let info = JVInspectorController.inspector(ofObject: view.connection!)
			info.show(nil)
			info.inspector.perform(#selector(JVConnectionInspector.selectTab(withIdentifier:)), with: "Ignores")
			return true;
		}
		
		if args.hasPrefix("-") { // parse commands/flags
			if argsArray[0].range(of: "p") != nil {
				permanent = true;
			}
			if argsArray[0].range(of: "m") != nil {
				member = false;
				message = true;
			}
			
			if argsArray[0].range(of: "n") != nil {
				member = true;
			}
			
			offset += 1; // lookup next arg.
		}
		
		// check for wrong number of arguments
		if argsArray.count < ( offset + ( message ? 1 : 0 ) + ( member ? 1 : 0 ) ) {
			return false
		}
		
		if member {
			memberString = argsArray[offset];
			offset += 1;
			args = argsArray[offset..<(argsArray.count - offset)].joined(separator: " ")
			// without that, the / test in message could have matched the / from the nick...
		}
		
		if message {
			if let range1 = args.range(of: "\""), let range2 = args.range(of: "\"", options: .backwards) {
				messageString = String(args[range1.upperBound ..< range2.lowerBound])
			} else if let range1 = args.range(of: "/"), let range2 = args.range(of: "/", options: .backwards) {
				messageString = String(args[range1.upperBound ..< range2.lowerBound])
			} else {
				messageString = argsArray[offset]
			}
			
			offset += messageString.components(separatedBy: " ").count
		}
		
		if offset < argsArray.count && argsArray[offset].count != 0 {
			rooms = Array(argsArray[offset..<argsArray.count - offset])
		}
		
		var rule: KAIgnoreRule
		if (memberString as NSString).isValidIRCMask {
			rule = KAIgnoreRule(forUser: nil, mask: memberString, message: messageString, inRooms: rooms, isPermanent: permanent, friendlyName: nil)
		} else {
			rule = KAIgnoreRule(forUser: memberString, message: messageString, inRooms: rooms, isPermanent: permanent, friendlyName: nil)
		}
		
		if let rules = MVConnectionsController.default.ignoreRules(for: view.connection!) {
			rules.add(rule)
		}
		
		return true;
	}
	
	private func handleUnignore(arguments args1: String, in view: JVChatViewController!) -> Bool {
		var args = args1
		// USAGE: /unignore -[m|n] [nickname|/regex/] ["message"|/regex/|word] [#rooms ...]
		// m is to specify a message
		// n is to specify a nickname
		
		// EXAMPLES:
		// /unignore - will open a GUI window to add and manage ignores
		// /unignore Loser23094 - unignore Loser23094 in all rooms
		// /unignore -m "is listening" - unignore any message that has "is listening" from everyone
		// /unignore -m /is listening .*/ - unignore the message expression "is listening *" from everyone
		// /unignore -mn /eevyl.*/ /is listening .*/ #adium #colloquy #here
		// /unignore -n /bunny.*/ - unignore users whose nick starts with bunny in all rooms
		
		let argsArray = args.components(separatedBy: " ")
		var messageString: String = ""
		var rooms = [String]()
		var memberString: String = ""
		var member = true;
		var message = false;
		var offset = 0;
		
		if args.count == 0 {
			let info = JVInspectorController.inspector(ofObject: view.connection!)
			info.show(nil)
			info.inspector.perform(#selector(JVConnectionInspector.selectTab(withIdentifier:)), with: "Ignores")
			return true;
		}
		
		if args.hasPrefix("-") { // parse commands/flags
			if argsArray[0].range(of: "m") != nil {
				member = false;
				message = true;
			}
			
			if argsArray[0].range(of: "n") != nil {
				member = true
			}
			
			offset += 1; // lookup next arg.
		}
		
		// check for wrong number of arguments
		if( argsArray.count < ( offset + ( message ? 1 : 0 ) + ( member ? 1 : 0 ) ) ) {
			return false;
		}
		
		if member {
			memberString = argsArray[offset];
			offset += 1;
			args = argsArray[offset...(argsArray.count - offset)].joined(separator: " ")
			// without that, the / test in message could have matched the / from the nick...
		}
		
		if message {
			if let range1 = args.range(of: "\"") {
				let range2 = args.range(of: "\"", options: .backwards)!
				messageString = String(args[range1.upperBound ..< range2.lowerBound])
			} else if let range1 = args.range(of: "/") {
				let range2 = args.range(of: "/", options: .backwards)!
				messageString = String(args[range1.upperBound ..< range2.lowerBound])
			} else {
				messageString = argsArray[offset]
			}
			
			offset += messageString.components(separatedBy: " ").count
		}
		
		if offset < argsArray.count && argsArray[offset].count != 0 {
			rooms = Array(argsArray[offset..<(argsArray.count - offset)])
		}
		
		guard let rules = MVConnectionsController.default.ignoreRules(for: view.connection!) else {
			return true
		}
		var i = 0
		while i < rules.count {
			let rule = rules[i] as! KAIgnoreRule
			if( ( rule.user == nil || rule.user!.isCaseInsensitiveEqual(to: memberString) ) && ( rule.message == nil || rule.message!.isCaseInsensitiveEqual(to: messageString) ) && ( rule.rooms == nil || rule.rooms! == rooms ) ) {
				rules.removeObject(at: i)
				i -= 1;
				break;
			}
			i += 1
		}
		
		return true;
	}
	
	public func processUserCommand(_ command1: String, withArguments arguments: NSAttributedString, to connection: MVChatConnection?, inView view: JVChatViewController?) -> Bool {
		let command = command1.lowercased()
		let isChatRoom = view is JVChatRoomPanel
		let isDirectChat = view is JVDirectChatPanel
	
		let chat = view as? JVDirectChatPanel
		let room = view as? JVChatRoomPanel
		
		if isChatRoom || isDirectChat {
			switch command {
			case "me", "action", "say":
				if arguments.length != 0 {
					let message = JVMutableChatMessage(text: arguments, sender: chat!.connection!.localUser)
					if command == "me" || command == "action" {
						// This is so plugins can process /me actions as well
						// We're avoiding /say for now, as that really should just output exactly what
						// the input was so we should still bypass plugins for /say
						
						message.isAction = true
						chat?.send(message)
						chat?.echoSentMessageToDisplay(message)
						
					} else {
						if let room = room, isChatRoom {
							(room.target as AnyObject?)?.sendMessage(message.body(), asAction: false)
						} else if let chat = chat {
							(chat.target as AnyObject?)?.sendMessage(message.body(), withEncoding: chat.encoding, asAction: false)
						}
						chat?.echoSentMessageToDisplay(message)
					}
					return true;
				}
				
			case "clear":
				if arguments.length == 0 {
					chat?.clearDisplay(nil)
					return true
				}
				
			case "console":
				let controller = JVChatController.default.chatConsole(for: chat!.connection!, ifExists: false)
				controller?.windowController?.show(controller!)
				return true
				
			case "reload":
				if arguments.string.caseInsensitiveCompare("style") == .orderedSame {
					chat?._reloadCurrentStyle(nil)
					return true
				}
				
			case "whois", "wi", "wii":
				let scanner = Scanner(string: arguments.string)
				var nick: NSString? = nil;
				scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &nick)
				if let user = connection?.chatUsers(withNickname: nick! as String).first {
					JVInspectorController.inspector(ofObject: user).show(nil)
					return true
				} else {
					return false
				}
				
			default:
				break
			}
		}
	
		if isChatRoom {
			switch command {
			case "leave", "part":
				if arguments.length == 0 {
					return handlePart(arguments: (room?.target as? MVChatRoom)?.name, for: room?.connection)
				} else {
					return handlePart(arguments: arguments.string, for: room?.connection)
				}
				
			case "topic", "t":
				if arguments.length == 0 && connection?.type == .ircType {
					_ = room?.display.windowScriptObject.callWebScriptMethod("toggleTopic", withArguments: nil)
					return true;
				} else if arguments.length != 0 {
					(room!.target as AnyObject?)?.changeTopic(arguments)
					return true;
				} else {
					return false;
				}
				
			case "names":
				if arguments.string.count == 0 {
					room?.windowController?.openViewsDrawer(nil)
					if let wc = room?.windowController, let room = room, wc.isListItemExpanded(room) {
						wc.collapse(room)
					} else {
						room?.windowController?.expand(room!)
					}
					return true;
				}
				
			case "cycle", "hop":
				if arguments.string.count == 0 {
					room?.partChat(nil)
					room?.joinChat(nil)
					return true
				}
				
			case "invite":
				if connection?.type == .ircType {
					var nick: NSString? = nil;
					var roomName: NSString? = nil;
					let whitespace = CharacterSet.whitespacesAndNewlines
					let scanner = Scanner(string: arguments.string)
					
					scanner.scanUpToCharacters(from: whitespace, into: &nick)
					guard let nick1 = nick, nick1.length > 0 else {
						return false
					}
					if !scanner.isAtEnd {
						scanner.scanUpToCharacters(from: whitespace, into: &roomName)
					}
					
					connection?.sendRawMessage("INVITE \(nick1) \(roomName ?? room!.target!)")
					return true
				}
				
			case "help":
				NSWorkspace.shared.open(URL(string: "http://project.colloquy.info/wiki/Documentation/CommandReference")!)
				return true

			case "kick":
				var member: NSString? = nil;
				let scanner = Scanner(string: arguments.string)
				
				scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &member)
				guard let member1 = member, member1.length > 0 else {
					return false
				}
				
				var reason: NSAttributedString? = nil;
				if( arguments.length >= scanner.scanLocation + 1 ) {
					reason = arguments.attributedSubstring(from: NSMakeRange(scanner.scanLocation + 1, arguments.length - scanner.scanLocation - 1))
				}
				
				if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: member1 as String)?.first {
					(room?.target as AnyObject?)?.kickOutMemberUser(user, forReason: reason)
				}
				return true

			case "kickban", "bankick", "bk", "kb":
				var member1: NSString? = nil;
				let scanner = Scanner(string: arguments.string)
				
				scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &member1)
				guard var member = member1 as String?, member.count > 0 else {
					return false
				}
				
				var reason: NSAttributedString? = nil;
				if arguments.length >= scanner.scanLocation + 1 {
					reason = arguments.attributedSubstring(from: NSMakeRange(scanner.scanLocation + 1, (arguments.length - scanner.scanLocation - 1)))
				}
				
				var user: MVChatUser? = nil;
				if member.hasCaseInsensitiveSubstring("!") || member.hasCaseInsensitiveSubstring("@")  {
					if !member.hasCaseInsensitiveSubstring("!") && member.hasCaseInsensitiveSubstring("@") {
						member = "*!*" + member
					}
					user = MVChatUser.wildcardUser(from: member)
				} else {
					user = (room?.target as AnyObject?)?.memberUsers(withNickname: member)?.first
				}
				
				if let user = user {
					(room?.target as AnyObject?)?.addBan(for: user)
					(room?.target as AnyObject?)?.kickOutMemberUser(user, forReason: reason)
					return true
				}
				return false;

			case "op":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.setMode(.operatorMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "deop":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.removeMode(.operatorMode, forMemberUser: user)
						}
					}
				}
				return true

			case "halfop":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.setMode(.halfOperatorMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "dehalfop":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.removeMode(.halfOperatorMode, forMemberUser: user)
						}
					}
				}
				return true

			case "voice":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.setMode(.voicedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "devoice":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.removeMode(.voicedMode, forMemberUser: user)
						}
					}
				}
				return true

			case "quiet":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.setDisciplineMode(.disciplineQuietedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "dequiet":
				let args = arguments.string.components(separatedBy: " ")
				for arg in args {
					if arg.count > 0 {
						if let user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first {
							(room?.target as AnyObject?)?.remove(.disciplineQuietedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "ban":
				let args = arguments.string.components(separatedBy: " ")
				for arg1 in args {
					var arg = arg1
					var user: MVChatUser?
					guard arg.count != 0 else {
						continue
					}
					if arg.hasCaseInsensitiveSubstring("!") || arg.hasCaseInsensitiveSubstring("@") || (room?.target as AnyObject?)?.memberUsers(withNickname: arg) == nil {
						if !arg.hasCaseInsensitiveSubstring("!") && arg.hasCaseInsensitiveSubstring("@") {
						arg = "*!*" + arg;
						}
						user = MVChatUser.wildcardUser(from: arg)
					} else {
						user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first
					}
					
					if let user = user {
						(room?.target as AnyObject?)?.addBan(for: user)
					}
				}
				return true
				
			case "unban":
				let args = arguments.string.components(separatedBy: " ")
				for arg1 in args {
					var arg = arg1
					var user: MVChatUser?
					guard arg.count != 0 else {
						continue
					}
					if arg.hasCaseInsensitiveSubstring("!") || arg.hasCaseInsensitiveSubstring("@") || (room?.target as AnyObject?)?.memberUsers(withNickname: arg) == nil {
						if !arg.hasCaseInsensitiveSubstring("!") && arg.hasCaseInsensitiveSubstring("@") {
							arg = "*!*" + arg;
						}
						user = MVChatUser.wildcardUser(from: arg)
					} else {
						user = (room?.target as AnyObject?)?.memberUsers(withNickname: arg)?.first
					}
					
					if let user = user {
						(room?.target as AnyObject?)?.removeBan(for: user)
					}
				}
				return true

			default:
				break
			}
		}
		
		switch command {
		case "msg", "query":
			return handleMessage(command: command1, with: arguments, for: connection, alwaysShow: isChatRoom || isDirectChat)
			
		case "amsg", "ame", "broadcast", "bract":
			return handleMassMessage(command: command1, with: arguments, for: connection)
			
		case "away":
			connection?.awayStatusMessage = arguments
			return true
			
		case "aaway":
			return handleMassAway(message: arguments)
			
		case "anick":
			return handleMassNickChange(nickname: arguments.string)
			
		case "j", "join":
			return handleJoin(arguments: arguments.string, for: connection)
			
		case "leave", "part":
			return handlePart(arguments: arguments.string, for: connection)
			
		case "server":
			return handleServerConnect(arguments: arguments.string)
			
		case "dcc":
			var subcmd: NSString? = nil;
			let scanner = Scanner(string: arguments.string)
			scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &subcmd)
			
			if (subcmd?.caseInsensitiveCompare("send") == .orderedSame) {
				return handleFileSend(arguments: arguments.string, for: connection)
			} else if subcmd?.caseInsensitiveCompare("chat") == .orderedSame {
				var nick: NSString?
				scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &nick)
				
				var user: MVChatUser?
				user = connection?.chatUsers(withNickname: nick! as String).first
				user?.startDirectChat(nil)
				
				return true
			}
			
			return false;
			
		case "raw", "quote":
			connection?.sendRawMessage(arguments.string, immediately: true)
			return true

		case "umode":
			guard connection?.type == .ircType else {
				return false
			}
			
			connection?.sendRawMessage("MODE \(connection!.nickname ?? "") \(arguments.string)")
			return true
			
		case "ctcp":
			if connection?.type == .ircType {
				return handleCTCP(arguments: arguments.string, for: connection)
			}

		case "wi":
			connection?.sendRawMessage("WHOIS \(arguments.string)")
			return true
			
		case "wii":
			connection?.sendRawMessage("WHOIS \(arguments.string) \(arguments.string)")
			return true
			
		case "list":
			guard let browser = JVChatRoomBrowser(for: connection) else {
				return true
			}
			connection?.fetchChatRoomList()
			browser.showWindow(nil)
			browser.show(nil)
			browser.filter = arguments.string
			return true

		case "reconnect":
			connection?.connect()
			return true
			
		case "exit":
			NSApplication.shared.terminate(nil)
			return true
			
		case "ignore":
			return handleIgnore(arguments: arguments.string, in: room)
			
		case "unignore":
			return handleUnignore(arguments: arguments.string, in: room)
			
		case "invite":
			guard connection?.type == .ircType else {
				return false
			}
			var nick1: NSString?
			var roomName1: NSString?
			let whitespace = CharacterSet.whitespacesAndNewlines
			let scanner = Scanner(string: arguments.string)
			
			scanner.scanUpToCharacters(from: whitespace, into: &nick1)
			if !scanner.isAtEnd {
				scanner.scanUpToCharacters(from: whitespace, into: &roomName1)
			}
			guard let nick = nick1 as String?, let roomName = roomName1 as String?, nick.count != 0 && roomName.count != 0 else {
				return false
			}
			
			connection?.sendRawMessage("INVITE \(nick) \(roomName)")
			return true
			
		case "reload":
			switch arguments.string.lowercased() {
			case "plugins", "scripts":
				MVChatPluginManager.default.reloadPlugins()
				return true
				
			case "styles":
				JVStyle.scanForStyles()
				return true
				
			case "emoticons":
				JVEmoticonSet.scanForEmoticonSets()
				return true
				
			case "all":
				MVChatPluginManager.default.reloadPlugins()
				JVEmoticonSet.scanForEmoticonSets()
				JVStyle.scanForStyles()
				if isChatRoom || isDirectChat {
					chat?._reloadCurrentStyle(nil)
				}
				return true
				
			default:
				return false
			}
		case "globops":
			guard connection?.type == .ircType else {
				return false
			}
			connection?.sendRawMessage("\(command) :\(arguments.string)")
			
		case "notice", "onotice":
			guard connection?.type == .ircType else {
				return false
			}
			var targetPrefix: NSString? = nil;
			var target: NSString? = nil;
			var message: NSString? = nil;
			let whitespace = CharacterSet.whitespacesAndNewlines
			let prefixes = (connection!.chatRoomNamePrefixes! as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
			prefixes.addCharacters(in: "@")
			
			let scanner = Scanner(string: arguments.string)
			if scanner.scanCharacters(from: prefixes as CharacterSet, into: &targetPrefix) || !isChatRoom {
				scanner.scanUpToCharacters(from: whitespace, into: &target)
				
				if let targetPrefix = targetPrefix as String? {
					target = (targetPrefix + (target! as String)) as NSString
				}
			} else if isChatRoom {
				if command.caseInsensitiveCompare("onotice") == .orderedSame {
					target = (room?.target as? MVChatRoom)?.name as NSString?
				} else {
					scanner.scanUpToCharacters(from: whitespace, into: &target)
				}
			}
			
			scanner.scanUpToCharacters(from: whitespace, into: nil)
			scanner.scanUpToCharacters(from: CharacterSet(charactersIn: "\n"), into: &message)
			
			guard let target2 = target as String?, let message1 = message as String?, target2.count != 0 && message1.count != 0 else {
				return true
			}
			var target1 = target2
			
			if command.caseInsensitiveCompare("onotice") == .orderedSame && !target1.hasPrefix("@") {
				target1 = "@" + connection!.properName(forChatRoomNamed: target1)
			}
			
			connection?.sendRawMessage("NOTICE \(target1) :\(message1)")
			
			let chanSet = connection!.chatRoomNamePrefixes;
			var chatView: JVDirectChatPanel? = nil;
			
			// this is an IRC specific command for sending to room operators only.
			if target1.hasPrefix("@") && target1.count > 1 {
				target1 = String(target1[target1.index(after: target1.startIndex) ..< target1.endIndex])
			}
			
			if chanSet?.contains(UnicodeScalar((target1 as NSString).character(at: 0))!) ?? true {
				if let room = connection?.joinedChatRoom(withName: target1) as MVChatRoom? {
					chatView = JVChatController.default.chatViewController(for: room, ifExists: true)
				}
			}
			
			if chatView == nil {
				if let user = connection?.chatUsers(withNickname: target1).first {
					chatView = JVChatController.default.chatViewController(for: user, ifExists: true)
				}
			}
			
			if let chatView = chatView {
				let cmessage = JVMutableChatMessage(text: message1, sender: connection?.localUser)
				cmessage.type = .noticeType
				chatView.echoSentMessageToDisplay(cmessage)
			}
			
			return true;

		case "nick":
			let newNickname = arguments.string
			if newNickname.count != 0 {
				connection?.nickname = newNickname
			}
			return true
			
		case "google", "search":
			guard let saveStr = arguments.string.encodingIllegalURLCharacters else {
				return true
			}
			let url = URL(string: "http://www.google.com/search?q=\(saveStr)")!
			let options = UserDefaults.standard.bool(forKey: "JVURLOpensInBackground") ? NSWorkspace.LaunchOptions.default : NSWorkspace.LaunchOptions.withoutActivation
			
			NSWorkspace.shared.open([url], withAppBundleIdentifier: nil, options: options, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
			
			return true
			
		default:
			break
		}
		
		return false
	}
}
