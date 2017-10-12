//
//  JVSpeechController.swift
//  Colloquy (Application)
//
//  Created by C.W. Betts on 10/12/17.
//  Copyright © 2017 Colloquy Project. All rights reserved.
//

import Cocoa

@objc(JVSpeechController)
public class JVSpeechController: NSObject, NSSpeechSynthesizerDelegate {
	@objc(sharedSpeechController)
	public static let shared = JVSpeechController()
	private var speechQueue = [(text: String, voice: NSSpeechSynthesizer.VoiceName)]()
	private let synthesizers: [NSSpeechSynthesizer]

	override init() {
		synthesizers = [NSSpeechSynthesizer(voice: nil)!, NSSpeechSynthesizer(voice: nil)!, NSSpeechSynthesizer(voice: nil)!]
		super.init()
		
		for synthesizer in synthesizers {
			synthesizer.delegate = self
		}
		speechQueue.reserveCapacity(15)
	}
	
	@objc(startSpeakingString:usingVoice:)
	public func startSpeaking(_ string: String, usingVoice voice: NSSpeechSynthesizer.VoiceName) {
		for synth in synthesizers {
			if !synth.isSpeaking {
				synth.setVoice(voice)
				synth.startSpeaking(string)
				return
			}
		}

		// Limit the number of outstanding strings to 15. This will prevent massive amounts of TTS flooding
		// when you get a channel flood or re-connect to a dircproxy server. Remove the oldest string from
		// the queue and then insert the new string onto the end.
		if speechQueue.count > 15 {
			speechQueue.remove(at: 0)
		}
		
		speechQueue.append((text: string, voice: voice))
	}
	
	public func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
		if speechQueue.count != 0  {
			let nextSpeech = speechQueue.removeFirst()
			sender.setVoice(nextSpeech.voice)
			sender.startSpeaking(nextSpeech.text)
		}
	}
}
