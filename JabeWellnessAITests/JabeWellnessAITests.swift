//
//  JabeWellnessAITests.swift
//  JabeWellnessAITests
//
//  Created by Joel Reamosio Abelarde on 5/13/26.
//

import Testing
import Foundation
@testable import JabeWellnessAI

struct JabeWellnessAITests {

    // ChatSession.dominantMood should reflect the mood that occurs most often across
    // the conversation, not just whichever mood the first tagged message happened to have.
    @Test func dominantMoodReflectsMostFrequentMoodNotFirst() async throws {
        let messages = [
            ChatMessage(content: "I'm so anxious about this",       isUser: true,  mood: .anxious, timestamp: Date()),
            ChatMessage(content: "It'll be okay, tell me more",     isUser: false, mood: nil,       timestamp: Date()),
            ChatMessage(content: "Actually I feel great now",       isUser: true,  mood: .happy,    timestamp: Date()),
            ChatMessage(content: "That's wonderful to hear!",       isUser: false, mood: nil,       timestamp: Date()),
            ChatMessage(content: "Yeah I'm really happy about it",  isUser: true,  mood: .happy,    timestamp: Date()),
        ]

        let session = ChatSession(messages: messages)

        #expect(session.dominantMood == .happy)
    }

    @Test func dominantMoodFallsBackToNeutralWhenNoMoodsPresent() async throws {
        let messages = [
            ChatMessage(content: "Hello", isUser: true,  mood: nil, timestamp: Date()),
            ChatMessage(content: "Hi!",   isUser: false, mood: nil, timestamp: Date()),
        ]

        let session = ChatSession(messages: messages)

        #expect(session.dominantMood == .neutral)
    }

    // MARK: - Trial window

    private func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    @Test func trialIsActiveOnTheDayItStarts() async throws {
        let start = date(daysAgo: 0)
        #expect(PremiumManager.isInTrial(start: start, now: Date(), trialDays: 7))
        #expect(PremiumManager.trialDaysRemaining(start: start, now: Date(), trialDays: 7) == 7)
    }

    @Test func trialCountsDownAsDaysElapse() async throws {
        #expect(PremiumManager.trialDaysRemaining(start: date(daysAgo: 3), now: Date(), trialDays: 7) == 4)
        #expect(PremiumManager.isInTrial(start: date(daysAgo: 3), now: Date(), trialDays: 7))
    }

    @Test func trialExpiresOnTheFinalDayAndStaysExpired() async throws {
        #expect(!PremiumManager.isInTrial(start: date(daysAgo: 7),  now: Date(), trialDays: 7))
        #expect(!PremiumManager.isInTrial(start: date(daysAgo: 30), now: Date(), trialDays: 7))
        #expect(PremiumManager.trialDaysRemaining(start: date(daysAgo: 30), now: Date(), trialDays: 7) == 0)
    }

    // A start date in the future means the device clock moved backwards. That must not
    // read as more trial than a fresh install gets.
    @Test func trialNeverReportsMoreDaysThanTheTrialLength() async throws {
        let future = Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date()
        #expect(PremiumManager.trialDaysRemaining(start: future, now: Date(), trialDays: 7) == 7)
    }

    // MARK: - Entitlement state
    //
    // Reported 2026-08-15 on a physical iPhone 11 Pro Max: tapping "Unlock for $3.99" while
    // the free trial was still running completed the purchase, but the paywall neither
    // confirmed it nor closed, so it was tapped three more times. Root cause is that the
    // paywall observes isPremium (= isPurchased || isInTrial), which is ALREADY true for the
    // whole trial and stays true after buying. The value never changes, SwiftUI's .onChange
    // never fires, and nothing on screen moves. The entitlement SOURCE has to be observable,
    // not just the boolean "is this user entitled".

    @Test func buyingDuringTheTrialChangesTheObservedState() async throws {
        let duringTrial = PremiumManager.entitlementState(isPurchased: false, isInTrial: true,  trialDaysRemaining: 5)
        // isInTrial is suppressed the moment isPurchased flips — see PremiumManager.isInTrial.
        let afterBuying = PremiumManager.entitlementState(isPurchased: true,  isInTrial: false, trialDaysRemaining: 0)

        #expect(duringTrial != afterBuying)
        #expect(afterBuying == .purchased)
    }

    // Defensive: even if both facts are somehow true at once, money beats a countdown.
    @Test func aCompletedPurchaseOutranksAnActiveTrial() async throws {
        #expect(PremiumManager.entitlementState(isPurchased: true, isInTrial: true, trialDaysRemaining: 5) == .purchased)
    }

    @Test func anActiveTrialCarriesItsRemainingDays() async throws {
        #expect(PremiumManager.entitlementState(isPurchased: false, isInTrial: true, trialDaysRemaining: 3)
                == .trial(daysRemaining: 3))
    }

    @Test func noPurchaseAndNoTrialIsLocked() async throws {
        #expect(PremiumManager.entitlementState(isPurchased: false, isInTrial: false, trialDaysRemaining: 0) == .locked)
    }

    // The trial anchor has to survive deleting the app, so it lives in the Keychain
    // rather than UserDefaults — a UserDefaults anchor granted a new trial per reinstall.
    // MARK: - Feature gating
    //
    // Until 2026-08-18 nothing in the app consulted entitlement: isPremium and
    // entitlementState were read in three cosmetic places and the $3.99 purchase
    // unlocked nothing. These pin the predicate every gated feature now asks.

    @Test func lockedUsersCannotReachPremiumFeatures() async throws {
        #expect(PremiumManager.isFeatureUnlocked(.locked) == false)
    }

    @Test func trialUsersReachPremiumFeatures() async throws {
        #expect(PremiumManager.isFeatureUnlocked(.trial(daysRemaining: 7)) == true)
        #expect(PremiumManager.isFeatureUnlocked(.trial(daysRemaining: 1)) == true)
    }

    @Test func purchasersReachPremiumFeatures() async throws {
        #expect(PremiumManager.isFeatureUnlocked(.purchased) == true)
    }

    // The gate must agree with the state machine feeding it, or a user can be
    // entitled by one and refused by the other.
    @Test func theGateAgreesWithEveryEntitlementState() async throws {
        let purchased = PremiumManager.entitlementState(isPurchased: true,  isInTrial: false, trialDaysRemaining: 0)
        let trialing  = PremiumManager.entitlementState(isPurchased: false, isInTrial: true,  trialDaysRemaining: 3)
        let locked    = PremiumManager.entitlementState(isPurchased: false, isInTrial: false, trialDaysRemaining: 0)

        #expect(PremiumManager.isFeatureUnlocked(purchased) == true)
        #expect(PremiumManager.isFeatureUnlocked(trialing)  == true)
        #expect(PremiumManager.isFeatureUnlocked(locked)    == false)
    }

    // An expired trial must close the gate. This is the case that would let a
    // non-paying user keep premium forever if the gate read the wrong thing.
    @Test func anExpiredTrialClosesTheGate() async throws {
        let start = Date()
        let elapsed = Calendar.current.date(byAdding: .day, value: 8, to: start) ?? start
        let inTrial = PremiumManager.isInTrial(start: start, now: elapsed, trialDays: 7)
        let state = PremiumManager.entitlementState(isPurchased: false,
                                                    isInTrial: inTrial,
                                                    trialDaysRemaining: 0)

        #expect(inTrial == false)
        #expect(PremiumManager.isFeatureUnlocked(state) == false)
    }

    @Test func trialAnchorRoundTripsThroughTheKeychain() async throws {
        let anchor = date(daysAgo: 2)
        TrialAnchorStore.save(anchor)

        let loaded = try #require(TrialAnchorStore.load())

        // ISO8601 serialization drops sub-second precision.
        #expect(abs(loaded.timeIntervalSince(anchor)) < 1.0)
    }

}
