//
//  Condition.swift
//  Apple Evaluation
//
//  Created by Keaton Burleson on 5/10/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct Condition: CustomStringConvertible {
    var letterGrade: String
    var generalDescription: String

    var description: String {
        return "Grade \(letterGrade): \(generalDescription)"
    }

    init(letterGrade: String, generalDescription: String) {
        self.letterGrade = letterGrade
        self.generalDescription = generalDescription
    }

    static let gradeA = Condition(letterGrade: "A", generalDescription: "Minor cosmetic scratches or scuffs on the bezel or casings, but overall in excellent cosmetic condition. 100% Fully Functional. The screen is pristine with no scratches, dead pixels or bruising.")

    static let gradeB = Condition(letterGrade: "B", generalDescription: "Minor cosmetic scratches or scuffs on the bezel and casing, possible minor dents on the corners of the casing, and show signs of use on  keyboard, trackpad and other highly utilized parts. 100% Fully Functional The Screen is pristine with no scratches, dead pixels or bruising.")

    static let gradeBMinus = Condition(letterGrade: "B-", generalDescription: "Shows significant signs of use and may have missing screws from the casing, cracked bezels or casings, and have may have significant dents on the corners or casing. Might have a worn keyboard, trackpad, palm rest and other surface areas. The screen is limited to only having up to 1-2 dead pixels, or a less than nickel size bruise. There may be a specific issue that is noted in the \"Special Condition Notes\". Might not be cosmetically perfect but still primarily functional and will get the job done.")

    static let gradeC = Condition(letterGrade: "C", generalDescription: "Machine is fully functional but has physical damage. If applicable, the machine you receive will have dented corners, the screen will have minor scratches and marks from the keyboard, the rest of the machine will show normal wear and tear including but not limited to scuffs and scratches.")

    static let gradeCMinus = Condition(letterGrade: "C-", generalDescription: "Machine is fully functional but has physical damage. If applicable, the machine you receive will have dented corners, maybe missing screws on the bottom panel and may have bent and separating base panel. The screen will have minor scratches and marks from the keyboard, the rest of the machine will show heavy use.")
}
