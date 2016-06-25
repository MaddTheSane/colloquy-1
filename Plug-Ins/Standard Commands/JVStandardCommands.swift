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

public class JVStandardCommands : NSObject, MVChatPlugin {
	public required init(manager: MVChatPluginManager) {
		super.init()
	}
	
	public func handleFileSendWithArguments(arguments: String!, forConnection connection: MVChatConnection!) -> Bool {
		var to: NSString?
		var path: NSString?
		let passive = NSUserDefaults.standardUserDefaults().boolForKey("JVSendFilesPassively")
		let scanner = NSScanner(string: arguments)
		scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: nil)
		scanner.scanCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: nil)
		scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &to)
		scanner.scanCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: nil)
		scanner.scanUpToCharactersFromSet(NSCharacterSet(charactersInString: "\n\r"), intoString: &path)
		guard let to2 = to where to2.length > 0 else {
			return false
		}
		var directory: ObjCBool = false
		path = path?.stringByStandardizingPath as NSString?
		if let path = path where path.length > 0 && !NSFileManager.defaultManager().fileExistsAtPath(path as String, isDirectory: &directory) {
			return true
		}
		if directory {
			return true
		}
		
		let user = connection.chatUsersWithNickname(to2 as String).first
		
		if let path = path where path.length > 0 {
			NSNotificationCenter.chatCenter().postNotificationName(MVFileTransferStartedNotification, object: user?.sendFile(path as String, passively: passive))
		} else {
			user?.sendFile(nil)
		}
		return true
	}
	
	public func handleCTCPWithArguments(arguments: String, forConnection connection: MVChatConnection!) -> Bool {
		var to: NSString?, ctcpRequest: NSString?, ctcpArgs: NSString?
		let scanner = NSScanner(string: arguments)
		
		scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceCharacterSet(), intoString: &to)
		scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &ctcpRequest)
		scanner.scanUpToCharactersFromSet(NSCharacterSet(charactersInString: "\n\r"), intoString: &ctcpArgs)
		
		guard let to2 = to as? String, ctcpRequest2 = ctcpRequest as? String where to2.characters.count != 0 && ctcpRequest2.characters.count != 0 else {
			return false
		}
		if to == nil || to!.length == 0 || ctcpRequest == nil || ctcpRequest!.length == 0 {
			return false;
		}
		
		let user = connection.chatUsersWithNickname(to2).first
		
		user?.sendSubcodeRequest(ctcpRequest2, withArguments: ctcpArgs)
		return true;
	}
	
	public func handleServerConnectWithArguments(arguments: String!) -> Bool {
		if let _ = arguments?.rangeOfString("://"), url = NSURL(string: arguments) {
			MVConnectionsController.defaultController().handleURL(url, andConnectIfPossible: true)
		} else if let arguments = arguments where arguments.characters.count > 0 {
			var address: NSString?
			var port: Int32 = 0
			let scanner = NSScanner(string: arguments)
			scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &address)
			scanner.scanInt(&port)
			var url: NSURL?
			
			if let address = address {
				if port != 0 {
					url = NSURL(string: "irc://\(address.stringByEncodingIllegalURLCharacters ?? ""):\(port)")
				} else {
					url = NSURL(string: "irc://\(address.stringByEncodingIllegalURLCharacters ?? "")")
				}
			} else {
				MVConnectionsController.defaultController().newConnection(nil)
			}
			
			if let url = url {
				MVConnectionsController.defaultController().handleURL(url, andConnectIfPossible: true)
			}
		} else {
			MVConnectionsController.defaultController().newConnection(nil)
		}
		return true
	}
	
	public func handleJoinWithArguments(arguments: String!, forConnection connection: MVChatConnection!) -> Bool {
		let channels = arguments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).componentsSeparatedByString(",")
		if channels.count == 1 {
			connection.joinChatRoomNamed(arguments.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
			return true
		} else if channels.count > 1 {
			/*		
			for( __strong NSString *channel in channels ) {
			channel = [channel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if( channel.length )
			[(NSMutableArray *)channels addObject:channel];
			}
			*/
			connection.joinChatRoomsNamed(channels)
			return true
		} else {
			let browser = JVChatRoomBrowser(forConnection: connection)
			browser?.showWindow(nil)
			browser?.showRoomBrowser(nil)
			return true
		}
	}
	
	public func handlePartWithArguments(arguments: String!, forConnection connection: MVChatConnection!) -> Bool {
		let args = arguments.componentsSeparatedByString(" ")
		let channels = args[0].componentsSeparatedByString(",")
		
		let message = args[1..<(args.count - 1 - 1)].joinWithSeparator(" ")
		let reason = NSAttributedString(string: message)
		
		if channels.count == 1 {
			connection.joinedChatRoomWithName(channels[0]).partWithReason(reason)
			return true;
		} else if channels.count > 1 {
			for channel in channels {
				let channel1 = channel.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				if channel1.characters.count != 0 {
					connection.joinedChatRoomWithName(channel1).partWithReason(reason)
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	public func handleMessageCommand(command: String!, withMessage message: NSAttributedString!, forConnection connection: MVChatConnection!, alwaysShow always: Bool) -> Bool {
		var to1: NSString?
		var msg: NSAttributedString?
		let scanner = NSScanner(string: message.string)
		
		scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &to1)
		
		guard let to = to1 where to.length > 0 else {
			return false
		}
		
		if message.length >= scanner.scanLocation + 1 {
			scanner.scanLocation += 1
			msg = message.attributedSubstringFromRange(NSMakeRange(scanner.scanLocation, message.length - scanner.scanLocation))
		}
		
		var show = false
		show = ( command.caseInsensitiveCompare("query") == .OrderedSame ? true : show )
		if let msg = msg where msg.length > 0 {
			show = true
		}
		show = ( always ? true : show );
		var chatView: JVDirectChatPanel? = nil

		// this is an IRC specific command for sending to room operators only.
		if connection.type == .IRCType {
			let scanner = NSScanner(string: to as String);
			scanner.charactersToBeSkipped = nil;
			scanner.scanCharactersFromSet(connection._nicknamePrefixes, intoString: nil)

			if scanner.scanLocation > 0 {
				let roomTargetName = to.substringFromIndex(scanner.scanLocation)
				if roomTargetName.characters.count > 1 && connection.chatRoomNamePrefixes.characterIsMember((roomTargetName as NSString).characterAtIndex(0)) {
					connection.sendRawMessage(NSString(string: "PRIVMSG \(to) :\(msg?.string ?? "")"))
					
					if let room = connection.joinedChatRoomWithName(roomTargetName) as MVChatRoom? {
						chatView = JVChatController.defaultController().chatViewControllerForRoom(room, ifExists: true)
					}
					
					let cmessage = JVMutableChatMessage(text: msg ?? "", sender: connection.localUser)
					chatView?.sendMessage(cmessage)
					chatView?.echoSentMessageToDisplay(cmessage)
					
					return true
				}
			}
		}
		
		var room: MVChatRoom?
		if command.caseInsensitiveCompare("msg") == .OrderedSame && to.length > 1 && connection.chatRoomNamePrefixes.characterIsMember(to.characterAtIndex(0)) {
			room = connection.joinedChatRoomWithName(to as String)
			if let room = room {
				chatView = JVChatController.defaultController().chatViewControllerForRoom(room, ifExists: true)
			}
		}
		
		var user: MVChatUser?
		if nil == chatView {
			user = connection.chatUsersWithNickname(to as String).first
			if let user = user {
				chatView = JVChatController.defaultController().chatViewControllerForUser(user, ifExists: !show)
			}
		}
		
		if let chatView = chatView, msg = msg where msg.length > 0 {
			let cmessage = JVMutableChatMessage(text: msg, sender: connection.localUser)
			chatView.sendMessage(cmessage)
			chatView.addMessageToHistory(msg)
			chatView.echoSentMessageToDisplay(cmessage)
			return true
		} else if let msg = msg where (user != nil || room != nil) && msg.length > 0 {
			let target: MVMessaging? = room ?? user
			target!.sendMessage(msg, withEncoding: room?.encoding ?? connection.encoding, asAction: false)
			return true
		}
		
		return false
	}
	
	public func handleMassMessageCommand(command: String, withMessage message: NSAttributedString!, forConnection connection: MVChatConnection!) -> Bool {
		guard message.length > 0 else {
			return false
		}
		
		let action: Bool = {
			let cmd = command.lowercaseString
			
			return cmd == "ame" || cmd == "bract"
		}()
		
		for room in (JVChatController.defaultController().chatViewControllersOfClass(JVChatRoomPanel.self) as! Set<JVChatRoomPanel>) {
			let cMessage = JVMutableChatMessage(text: message, sender: room.connection()?.localUser)
			cMessage.action = action
			room.sendMessage(cMessage)
			room.echoSentMessageToDisplay(cMessage)
		}
		
		return true
	}
	
	public func handleMassNickChangeWithName(nickname: String!) -> Bool {
		for item in MVConnectionsController.defaultController().connectedConnections {
			item.nickname = nickname;
		}
		return true;
	}
	
	public func handleMassAwayWithMessage(message: NSAttributedString?) -> Bool {
		for item in MVConnectionsController.defaultController().connectedConnections {
			item.awayStatusMessage = message;
		}
		return true;
	}
	
	public func handleIgnoreWithArguments(args1: String, inView view: JVChatViewController!) -> Bool {
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
		
		let argsArray = args.componentsSeparatedByString(" ")
		var memberString = "";
		var messageString = "";
		var rooms = [String]();
		var permanent = false;
		var member = true;
		var message = false;
		var offset = 0;
		
		if args.characters.count == 0 {
			let info = JVInspectorController.inspectorOfObject(view.connection()!)
			info.show(nil)
			info.inspector.performSelector(#selector(JVConnectionInspector.selectTabWithIdentifier(_:)), withObject: "Ignores")
			return true;
		}
		
		if args.hasPrefix("-") { // parse commands/flags
			if argsArray[0].rangeOfString("p") != nil {
				permanent = true;
			}
			if argsArray[0].rangeOfString("m") != nil {
				member = false;
				message = true;
			}
			
			if argsArray[0].rangeOfString("n") != nil {
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
			args = argsArray[offset..<(argsArray.count - offset)].joinWithSeparator(" ")
			// without that, the / test in message could have matched the / from the nick...
		}
		
		if message {
			if let range1 = args.rangeOfString("\"") {
				let range2 = args.rangeOfString("\"", options: .BackwardsSearch)!
				messageString = args[range1.last! ..< range2.first!]
			} else if let range1 = args.rangeOfString("/") {
				let range2 = args.rangeOfString("/", options: .BackwardsSearch)!
				messageString = args[range1.last! ..< range2.first!]
			} else {
				messageString = argsArray[offset]
			}
			
			offset += messageString.componentsSeparatedByString(" ").count
		}
		
		if offset < argsArray.count && argsArray[offset].characters.count != 0 {
			rooms = Array(argsArray[offset..<argsArray.count - offset])
		}
		
		var rule: KAIgnoreRule
		if (memberString as NSString).validIRCMask {
			rule = KAIgnoreRule(forUser: nil, mask: memberString, message: messageString, inRooms: rooms, isPermanent: permanent, friendlyName: nil)
		} else {
			rule = KAIgnoreRule(forUser: memberString, message: messageString, inRooms: rooms, isPermanent: permanent, friendlyName: nil)
		}
		
		let rules = MVConnectionsController.defaultController().ignoreRulesForConnection(view.connection())
		rules.addObject(rule)
		
		return true;
	}
	
	public func handleUnignoreWithArguments(args1: String, inView view: JVChatViewController!) -> Bool {
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
		
		let argsArray = args.componentsSeparatedByString(" ")
		var messageString: String = ""
		var rooms = [String]()
		var memberString: String = ""
		var member = true;
		var message = false;
		var offset = 0;
		
		if args.characters.count == 0 {
			let info = JVInspectorController.inspectorOfObject(view.connection()!)
			info.show(nil)
			info.inspector.performSelector(#selector(JVConnectionInspector.selectTabWithIdentifier(_:)), withObject: "Ignores")
			return true;
		}
		
		if args.hasPrefix("-") { // parse commands/flags
			if argsArray[0].rangeOfString("m") != nil {
				member = false;
				message = true;
			}
			
			if argsArray[0].rangeOfString("n") != nil {
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
			args = argsArray[offset...(argsArray.count - offset)].joinWithSeparator(" ")
			// without that, the / test in message could have matched the / from the nick...
		}
		
		if message {
			if let range1 = args.rangeOfString("\"") {
				let range2 = args.rangeOfString("\"", options: .BackwardsSearch)!
				messageString = args[range1.last! ..< range2.first!]
			} else if let range1 = args.rangeOfString("/") {
				let range2 = args.rangeOfString("/", options: .BackwardsSearch)!
				messageString = args[range1.last! ..< range2.first!]
			} else {
				messageString = argsArray[offset]
			}
			
			offset += messageString.componentsSeparatedByString(" ").count
		}
		
		if offset < argsArray.count && argsArray[offset].characters.count != 0 {
			rooms = Array(argsArray[offset..<(argsArray.count - offset)])
		}
		
		let rules = MVConnectionsController.defaultController().ignoreRulesForConnection(view.connection())
		var i = 0
		while i < rules.count {
			let rule = rules[i] as! KAIgnoreRule
			if( ( rule.user == nil || rule.user!.isCaseInsensitiveEqualToString(memberString) ) && ( rule.message == nil || rule.message!.isCaseInsensitiveEqualToString(messageString) ) && ( rule.rooms == nil || rule.rooms! == rooms ) ) {
				rules.removeObjectAtIndex(i)
				i -= 1;
				break;
			}
			i += 1
		}
		
		return true;
	}
	
	public override func processUserCommand(command1: String!, withArguments arguments: NSAttributedString!, toConnection connection: MVChatConnection!, inView view: JVChatViewController!) -> Bool {
		var command = command1
		let isChatRoom = view is JVChatRoomPanel
		let isDirectChat = view is JVDirectChatPanel;
		command = command.lowercaseString
	
		let chat = view as? JVDirectChatPanel
		let room = view as? JVChatRoomPanel
		
		if isChatRoom || isDirectChat {
			switch command {
			case "me", "action", "say":
				if arguments.length != 0 {
					let message = JVMutableChatMessage(text:arguments, sender:chat!.connection()!.localUser)
					if command == "me" || command == "action" {
						// This is so plugins can process /me actions as well
						// We're avoiding /say for now, as that really should just output exactly what
						// the input was so we should still bypass plugins for /say
						
						message.action = true
						chat?.sendMessage(message)
						chat?.echoSentMessageToDisplay(message)
						
					} else {
						if let room = room where isChatRoom {
							room.target?.sendMessage(message.body(), asAction: false)
						} else if let chat = chat {
							chat.target?.sendMessage(message.body(), withEncoding: chat.encoding, asAction: false)
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
				let controller = JVChatController.defaultController().chatConsoleForConnection(chat!.connection()!, ifExists: false)
				controller.windowController()?.showChatViewController(controller)
				return true
				
			case "reload":
				if arguments.string.caseInsensitiveCompare("style") == .OrderedSame {
					chat?._reloadCurrentStyle(nil)
					return true
				}
				
			case "whois", "wi", "wii":
				let scanner = NSScanner(string: arguments.string)
				var nick: NSString? = nil;
				scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &nick)
				if let user = connection.chatUsersWithNickname(nick! as String).first {
					JVInspectorController.inspectorOfObject(user).show(nil)
					return true
				} else {
					return false
				}
				
			default:
				break
			}
		}
	
		if isChatRoom {
			switch command.lowercaseString {
			case "leave", "part":
				if arguments.length == 0 {
					return handlePartWithArguments((room?.target as? MVChatRoom)?.name, forConnection: room?.connection())
				} else {
					return handlePartWithArguments(arguments.string, forConnection: room?.connection())
				}
				
			case "topic", "t":
				if arguments.length == 0 && connection.type == .IRCType {
					room?.display.windowScriptObject.callWebScriptMethod("toggleTopic", withArguments: nil)
					return true;
				} else if arguments.length != 0 {
					room!.target?.changeTopic(arguments)
					return true;
				} else {
					return false;
				}
				
			case "names":
				if arguments.string.characters.count == 0 {
					room?.windowController()?.openViewsDrawer(nil)
					if let wc = room?.windowController(), room = room where wc.isListItemExpanded(room) {
						wc.collapseListItem(room)
					} else {
						room?.windowController()?.expandListItem(room!)
					}
					return true;
				}
				
			case "cycle", "hop":
				if arguments.string.characters.count == 0 {
					room?.partChat(nil)
					room?.joinChat(nil)
					return true
				}
				
			case "invite":
				if connection.type == .IRCType {
					var nick: NSString? = nil;
					var roomName: NSString? = nil;
					let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
					let scanner = NSScanner(string: arguments.string)
					
					scanner.scanUpToCharactersFromSet(whitespace, intoString: &nick)
					guard let nick1 = nick where nick1.length > 0 else {
						return false
					}
					if !scanner.atEnd {
						scanner.scanUpToCharactersFromSet(whitespace, intoString: &roomName)
					}
					
					connection.sendRawMessage("INVITE \(nick1) \(roomName ?? room?.target!)")
					return true
				}
				
			case "help":
				NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://project.colloquy.info/wiki/Documentation/CommandReference")!)
				return true

			case "kick":
				var member: NSString? = nil;
				let scanner = NSScanner(string: arguments.string)
				
				scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &member)
				guard let member1 = member where member1.length > 0 else {
					return false
				}
				
				var reason: NSAttributedString? = nil;
				if( arguments.length >= scanner.scanLocation + 1 ) {
					reason = arguments.attributedSubstringFromRange(NSMakeRange(scanner.scanLocation + 1, arguments.length - scanner.scanLocation - 1))
				}
				
				if let user = room?.target?.memberUsersWithNickname(member1 as String).first {
					room?.target?.kickOutMemberUser(user, forReason: reason)
				}
				return true

			case "kickban", "bankick", "bk", "kb":
				var member1: NSString? = nil;
				let scanner = NSScanner(string: arguments.string)
				
				scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &member1)
				guard var member = member1 as? String where member.characters.count > 0 else {
					return false
				}
				
				var reason: NSAttributedString? = nil;
				if arguments.length >= scanner.scanLocation + 1 {
					reason = arguments.attributedSubstringFromRange(NSMakeRange(scanner.scanLocation + 1, (arguments.length - scanner.scanLocation - 1)))
				}
				
				var user: MVChatUser? = nil;
				if member.hasCaseInsensitiveSubstring("!") || member.hasCaseInsensitiveSubstring("@")  {
					if !member.hasCaseInsensitiveSubstring("!") && member.hasCaseInsensitiveSubstring("@") {
						member = "*!*" + member
					}
					user = MVChatUser.wildcardUserFromString(member)
				} else {
					user = room?.target?.memberUsersWithNickname(member).first
				}
				
				if let user = user {
					room?.target?.addBanForUser(user)
					room?.target?.kickOutMemberUser(user, forReason: reason)
					return true
				}
				return false;

			case "op":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.setMode(.OperatorMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "deop":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.removeMode(.OperatorMode, forMemberUser: user)
						}
					}
				}
				return true

			case "halfop":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.setMode(.HalfOperatorMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "dehalfop":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.removeMode(.HalfOperatorMode, forMemberUser: user)
						}
					}
				}
				return true

			case "voice":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.setMode(.VoicedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "devoice":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.removeMode(.VoicedMode, forMemberUser: user)
						}
					}
				}
				return true

			case "quiet":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.setDisciplineMode(.DisciplineQuietedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "dequiet":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg in args {
					if arg.characters.count > 0 {
						if let user = room?.target?.memberUsersWithNickname(arg).first {
							room?.target?.removeDisciplineMode(.DisciplineQuietedMode, forMemberUser: user)
						}
					}
				}
				return true
				
			case "ban":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg1 in args {
					var arg = arg1
					var user: MVChatUser?
					guard arg.characters.count != 0 else {
						continue
					}
					if arg.hasCaseInsensitiveSubstring("!") || arg.hasCaseInsensitiveSubstring("@") || room?.target?.memberUsersWithNickname(arg) == nil {
						if !arg.hasCaseInsensitiveSubstring("!") && arg.hasCaseInsensitiveSubstring("@") {
						arg = "*!*" + arg;
						}
						user = MVChatUser.wildcardUserFromString(arg)
					} else {
						user = room?.target?.memberUsersWithNickname(arg).first
					}
					
					if let user = user {
						room?.target?.addBanForUser(user)
					}
				}
				return true
				
			case "unban":
				let args = arguments.string.componentsSeparatedByString(" ")
				for arg1 in args {
					var arg = arg1
					var user: MVChatUser?
					guard arg.characters.count != 0 else {
						continue
					}
					if arg.hasCaseInsensitiveSubstring("!") || arg.hasCaseInsensitiveSubstring("@") || room?.target?.memberUsersWithNickname(arg) == nil {
						if !arg.hasCaseInsensitiveSubstring("!") && arg.hasCaseInsensitiveSubstring("@") {
							arg = "*!*" + arg;
						}
						user = MVChatUser.wildcardUserFromString(arg)
					} else {
						user = room?.target?.memberUsersWithNickname(arg).first
					}
					
					if let user = user {
						room?.target?.removeBanForUser(user)
					}
				}
				return true

			default:
				break
			}
		}
		
		switch command.lowercaseString {
		case "nick":
			let newNickname = arguments.string
			if newNickname.characters.count != 0 {
				connection.nickname = newNickname
			}
			return true
			
		case "google", "search":
			guard let saveStr = arguments.string.stringByEncodingIllegalURLCharacters else {
				return true
			}
			let url = NSURL(string: "http://www.google.com/search?q=\(saveStr)")!
			let options = NSUserDefaults.standardUserDefaults().boolForKey("JVURLOpensInBackground") ? NSWorkspaceLaunchOptions.Default : NSWorkspaceLaunchOptions.WithoutActivation
			
			NSWorkspace.sharedWorkspace().openURLs([url], withAppBundleIdentifier: nil, options: options, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
			
			return true
			
		default:
			break
		}

	/*
	if( ! [command caseInsensitiveCompare:@"msg"] || ! [command caseInsensitiveCompare:@"query"] ) {
	return [self handleMessageCommand:command withMessage:arguments forConnection:connection alwaysShow:( isChatRoom || isDirectChat )];
	} else if( ! [command caseInsensitiveCompare:@"amsg"] || ! [command caseInsensitiveCompare:@"ame"] || ! [command caseInsensitiveCompare:@"broadcast"] || ! [command caseInsensitiveCompare:@"bract"] ) {
	return [self handleMassMessageCommand:command withMessage:arguments forConnection:connection];
	} else if( ! [command caseInsensitiveCompare:@"away"] ) {
	[connection setAwayStatusMessage:arguments];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"aaway"] ) {
	return [self handleMassAwayWithMessage:arguments];
	} else if( ! [command caseInsensitiveCompare:@"anick"] ) {
	return [self handleMassNickChangeWithName:arguments.string];
	} else if( ! [command caseInsensitiveCompare:@"j"] || ! [command caseInsensitiveCompare:@"join"] ) {
	return [self handleJoinWithArguments:arguments.string forConnection:connection];
	} else if( ! [command caseInsensitiveCompare:@"leave"] || ! [command caseInsensitiveCompare:@"part"] ) {
	return [self handlePartWithArguments:arguments.string forConnection:connection];
	} else if( ! [command caseInsensitiveCompare:@"server"] ) {
	return [self handleServerConnectWithArguments:arguments.string];
	} else if( ! [command caseInsensitiveCompare:@"dcc"] ) {
	NSString *subcmd = nil;
	NSScanner *scanner = [NSScanner scannerWithString:arguments.string];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&subcmd];
	if( ! [subcmd caseInsensitiveCompare:@"send"] ) {
	return [self handleFileSendWithArguments:arguments.string forConnection:connection];
	} else if( ! [subcmd caseInsensitiveCompare:@"chat"] ) {
	NSString *nick = nil;
	[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&nick];
	
	MVChatUser *user = [[connection chatUsersWithNickname:nick] anyObject];
	[user startDirectChat:nil];
	return YES;
	}
	
	return NO;
	} else if( ! [command caseInsensitiveCompare:@"raw"] || ! [command caseInsensitiveCompare:@"quote"] ) {
	[connection sendRawMessage:arguments.string immediately:YES];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"umode"] && connection.type == MVChatConnectionIRCType ) {
	[connection sendRawMessage:[NSString stringWithFormat:@"MODE %@ %@", [connection nickname], arguments.string]];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"ctcp"] && connection.type == MVChatConnectionIRCType ) {
	return [self handleCTCPWithArguments:arguments.string forConnection:connection];
	} else if( ! [command caseInsensitiveCompare:@"wi"] ) {
	[connection sendRawMessage:[NSString stringWithFormat:@"WHOIS %@", arguments.string]];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"wii"] ) {
	[connection sendRawMessage:[NSString stringWithFormat:@"WHOIS %@ %@", arguments.string, arguments.string]];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"list"] ) {
	JVChatRoomBrowser *browser = [JVChatRoomBrowser chatRoomBrowserForConnection:connection];
	[connection fetchChatRoomList];
	[browser showWindow:nil];
	[browser showRoomBrowser:nil];
	browser.filter = arguments.string;
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"quit"] || ! [command caseInsensitiveCompare:@"disconnect"] ) {
	[connection disconnectWithReason:arguments];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"reconnect"] || ! [command caseInsensitiveCompare:@"server"] ) {
	[connection connect];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"exit"] ) {
	[[NSApplication sharedApplication] terminate:nil];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"ignore"] ) {
	return [self handleIgnoreWithArguments:arguments.string inView:room];
	} else if( ! [command caseInsensitiveCompare:@"unignore"] ) {
	return [self handleUnignoreWithArguments:arguments.string inView:room];
	} else if( ! [command caseInsensitiveCompare:@"invite"] && connection.type == MVChatConnectionIRCType ) {
	NSString *nick = nil;
	NSString *roomName = nil;
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSScanner *scanner = [NSScanner scannerWithString:arguments.string];
	
	[scanner scanUpToCharactersFromSet:whitespace intoString:&nick];
	if( ! nick.length || ! roomName.length ) return NO;
	if( ! [scanner isAtEnd] ) [scanner scanUpToCharactersFromSet:whitespace intoString:&roomName];
	
	[connection sendRawMessage:[NSString stringWithFormat:@"INVITE %@ %@", nick, roomName]];
	return YES;
	} else if( ! [command caseInsensitiveCompare:@"reload"] ) {
	if( ! [arguments.string caseInsensitiveCompare:@"plugins"] || ! [arguments.string caseInsensitiveCompare:@"scripts"] ) {
	[[MVChatPluginManager defaultManager] reloadPlugins];
	return YES;
	} else if( ! [arguments.string caseInsensitiveCompare:@"styles"] ) {
	[JVStyle scanForStyles];
	return YES;
	} else if( ! [arguments.string caseInsensitiveCompare:@"emoticons"] ) {
	[JVEmoticonSet scanForEmoticonSets];
	return YES;
	} else if( ! [arguments.string caseInsensitiveCompare:@"all"] ) {
	[[MVChatPluginManager defaultManager] reloadPlugins];
	[JVEmoticonSet scanForEmoticonSets];
	[JVStyle scanForStyles];
	if( isChatRoom || isDirectChat )
	[chat _reloadCurrentStyle:nil];
	return YES;
	}
	} else if( ! [command caseInsensitiveCompare:@"globops"] && connection.type == MVChatConnectionIRCType ) {
	[connection sendRawMessage:[NSString stringWithFormat:@"%@ :%@", command, arguments.string]];
	return YES;
	} else if( ( ! [command caseInsensitiveCompare:@"notice"] || ! [command caseInsensitiveCompare:@"onotice"] ) && connection.type == MVChatConnectionIRCType ) {
	NSString *targetPrefix = nil;
	NSString *target = nil;
	NSString *message = nil;
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSMutableCharacterSet *prefixes = [connection.chatRoomNamePrefixes mutableCopy];
	[prefixes addCharactersInString:@"@"];
	
	NSScanner *scanner = [NSScanner scannerWithString:arguments.string];
	if( [scanner scanCharactersFromSet:prefixes intoString:&targetPrefix] || ! isChatRoom ) {
	[scanner scanUpToCharactersFromSet:whitespace intoString:&target];
	if( targetPrefix.length ) target = [targetPrefix stringByAppendingString:target];
	} else if( isChatRoom ) {
	if( ! [command caseInsensitiveCompare:@"onotice"] )
	target = ((MVChatRoom *)room.target).name;
	else [scanner scanUpToCharactersFromSet:whitespace intoString:&target];
	}
	prefixes = nil;
	
	[scanner scanCharactersFromSet:whitespace intoString:NULL];
	[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"] intoString:&message];
	
	if( ! target.length || ! message.length ) return YES;
	
	if( ! [command caseInsensitiveCompare:@"onotice"] && ! [target hasPrefix:@"@"] )
	target = [@"@" stringByAppendingString:[connection properNameForChatRoomNamed:target]];
	
	[connection sendRawMessage:[NSString stringWithFormat:@"NOTICE %@ :%@", target, message]];
	
	NSCharacterSet *chanSet = connection.chatRoomNamePrefixes;
	JVDirectChatPanel *chatView = nil;
	
	// this is an IRC specific command for sending to room operators only.
	if( [target hasPrefix:@"@"] && target.length > 1 )
	target = [target substringFromIndex:1];
	
	if( ! chanSet || [chanSet characterIsMember:[target characterAtIndex:0]] ) {
	MVChatRoom *room = [connection joinedChatRoomWithName:target];
	if( room ) chatView = [[JVChatController defaultController] chatViewControllerForRoom:room ifExists:YES];
	}
	
	if( ! chatView ) {
	MVChatUser *user = [[connection chatUsersWithNickname:target] anyObject];
	if( user ) chatView = [[JVChatController defaultController] chatViewControllerForUser:user ifExists:YES];
	}
	
	if( chatView ) {
	JVMutableChatMessage *cmessage = [JVMutableChatMessage messageWithText:message sender:connection.localUser];
	[cmessage setType:JVChatMessageNoticeType];
	[chatView echoSentMessageToDisplay:cmessage];
	}
	
	return YES;
	}
	
	return NO;
*/

return false
	}
}
