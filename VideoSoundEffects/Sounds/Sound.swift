//
//  Created by Антон Лобанов on 03.11.2022.
//

import Foundation

enum Sound: String, CaseIterable, Identifiable {
	case cartoonVoiceLaugh = "cartoon-voice-laugh-343"
	case childrenHappyCountdown = "children-happy-countdown-923"
	case clownHornAtCircus = "clown-horn-at-circus-715"
	case fallingMaleScream = "falling-male-scream-391"
	case happyPartyHornSound = "happy-party-horn-sound-530"
	case jokeDrums = "joke-drums-578"
	case longPop = "long-pop-2358"
	case quickFunnyKiss = "quick-funny-kiss-2193"
	case sadGameOverTrombone = "sad-game-over-trombone-471"
	case smallCrowdLaughAndApplause = "small-crowd-laugh-and-applause-422"
	case winningAnExtraBonus = "winning-an-extra-bonus-2060"

	var id: String {
		self.rawValue
	}

	var fileName: String {
		self.rawValue
	}

	var fileType: String {
		"wav"
	}

	var emoji: String {
		switch self {
		case .cartoonVoiceLaugh:
			return "😂"
		case .fallingMaleScream:
			return "🕺"
		case .smallCrowdLaughAndApplause:
			return "👏"
		case .sadGameOverTrombone:
			return "💩"
		case .jokeDrums:
			return "🥁"
		case .happyPartyHornSound:
			return "🥳"
		case .clownHornAtCircus:
			return "🤡"
		case .childrenHappyCountdown:
			return "🌝"
		case .winningAnExtraBonus:
			return "🥇"
		case .quickFunnyKiss:
			return "👄"
		case .longPop:
			return "💨"
		}
	}
}
