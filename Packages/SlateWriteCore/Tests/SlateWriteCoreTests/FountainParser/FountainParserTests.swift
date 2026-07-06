import Testing
@testable import SlateWriteCore

@Suite("FountainParser — scene headings")
struct FountainSceneHeadingTests {
    @Test(arguments: [
        "INT. HOUSE - DAY",
        "EXT. BRICK'S POOL - DAY",
        "EST. CITY SKYLINE - NIGHT",
        "INT./EXT. RONNA'S CAR - NIGHT",
        "INT/EXT. OLYMPIA CIRCUS - NIGHT",
        "I/E. CAR - DAY",
    ])
    func standardPrefixes_parseAsSceneHeading(line: String) {
        let doc = FountainParser.parse(line)
        #expect(doc.elements.count == 1)
        #expect(doc.elements[0].type == .sceneHeading)
        #expect(doc.elements[0].text == line)
    }

    @Test func forcedSceneHeading_withLeadingDot() {
        let doc = FountainParser.parse(".SNIPER SCOPE POV")
        #expect(doc.elements[0].type == .sceneHeading)
        #expect(doc.elements[0].text == "SNIPER SCOPE POV")
    }

    @Test func leadingDotDot_isNotASceneHeading() {
        let doc = FountainParser.parse("...opening titles fade in.")
        #expect(doc.elements[0].type == .action)
    }

    @Test func sceneNumber_isExtractedFromTrailingHashes() {
        let doc = FountainParser.parse("INT. HOUSE - DAY #1#")
        #expect(doc.elements[0].type == .sceneHeading)
        #expect(doc.elements[0].sceneNumber == "1")
        #expect(doc.elements[0].text == "INT. HOUSE - DAY")
    }

    @Test func alphanumericSceneNumber_isExtracted() {
        let doc = FountainParser.parse("INT. HOUSE - DAY #110A#")
        #expect(doc.elements[0].sceneNumber == "110A")
    }

    @Test func lowercaseIntPrefix_isNotASceneHeading() {
        let doc = FountainParser.parse("interior decorating was her passion.")
        #expect(doc.elements[0].type == .action)
    }
}

@Suite("FountainParser — dialogue blocks")
struct FountainDialogueTests {
    @Test func characterCue_thenDialogue() {
        let doc = FountainParser.parse("BOB\nHello there.")
        #expect(doc.elements.map(\.type) == [.character, .dialogue])
        #expect(doc.elements[0].text == "BOB")
        #expect(doc.elements[1].text == "Hello there.")
    }

    @Test func characterWithExtension_parsesAsCharacter() {
        let doc = FountainParser.parse("BOB (V.O.)\nI remember it well.")
        #expect(doc.elements[0].type == .character)
        #expect(doc.elements[0].text == "BOB (V.O.)")
    }

    @Test func parenthetical_betweenCharacterAndDialogue() {
        let doc = FountainParser.parse("BOB\n(whispering)\nCome here.")
        #expect(doc.elements.map(\.type) == [.character, .parenthetical, .dialogue])
        #expect(doc.elements[1].text == "(whispering)")
    }

    @Test func allCapsLineWithoutFollowingText_isAction() {
        let doc = FountainParser.parse("SOMETHING LOUD HAPPENS")
        #expect(doc.elements[0].type == .action)
    }

    @Test func forcedCharacter_withAtSign() {
        let doc = FountainParser.parse("@McCLANE\nYippie ki-yay.")
        #expect(doc.elements[0].type == .character)
        #expect(doc.elements[0].text == "McCLANE")
    }

    @Test func dualDialogue_marksBothBlocks() {
        let doc = FountainParser.parse("BOB\nHi!\n\nALICE ^\nHey!")
        let characters = doc.elements.filter { $0.type == .character }
        #expect(characters.count == 2)
        #expect(characters[0].isDualDialogue)
        #expect(characters[1].isDualDialogue)
        #expect(characters[1].text == "ALICE")
    }

    @Test func multilineDialogue_staysOneElementPerLineGroup() {
        let doc = FountainParser.parse("BOB\nLine one.\nLine two.")
        #expect(doc.elements.map(\.type) == [.character, .dialogue])
        #expect(doc.elements[1].text == "Line one.\nLine two.")
    }
}

@Suite("FountainParser — transitions and misc")
struct FountainTransitionTests {
    @Test(arguments: ["CUT TO:", "SMASH CUT TO:", "DISSOLVE TO:"])
    func upperCaseEndingInTO_isTransition(line: String) {
        let doc = FountainParser.parse("Some action.\n\n\(line)\n\nINT. NEXT - DAY")
        #expect(doc.elements.map(\.type) == [.action, .transition, .sceneHeading])
    }

    @Test func forcedTransition_withGreaterThan() {
        let doc = FountainParser.parse("> Burn to white.")
        #expect(doc.elements[0].type == .transition)
        #expect(doc.elements[0].text == "Burn to white.")
    }

    @Test func centeredText_isCenteredAction() {
        let doc = FountainParser.parse("> THE END <")
        #expect(doc.elements[0].type == .action)
        #expect(doc.elements[0].isCentered)
        #expect(doc.elements[0].text == "THE END")
    }

    @Test func pageBreak_threeOrMoreEquals() {
        let doc = FountainParser.parse("The end of act one.\n\n===\n\nACT TWO begins.")
        #expect(doc.elements.map(\.type) == [.action, .pageBreak, .action])
    }

    @Test func section_andSynopsis_areCaptured() {
        let doc = FountainParser.parse("# Act 1\n\n= Bob's world falls apart.")
        #expect(doc.elements[0].type == .section)
        #expect(doc.elements[0].text == "Act 1")
        #expect(doc.elements[0].sectionDepth == 1)
        #expect(doc.elements[1].type == .synopsis)
        #expect(doc.elements[1].text == "Bob's world falls apart.")
    }

    @Test func lyrics_withTilde() {
        let doc = FountainParser.parse("~Willy Wonka! Willy Wonka!")
        #expect(doc.elements[0].type == .lyrics)
        #expect(doc.elements[0].text == "Willy Wonka! Willy Wonka!")
    }

    @Test func boneyard_isIgnored() {
        let doc = FountainParser.parse("Visible action.\n\n/* cut this\nwhole block */\n\nMore action.")
        #expect(doc.elements.map(\.type) == [.action, .action])
    }

    @Test func notes_areStrippedFromAction() {
        let doc = FountainParser.parse("He walks away. [[fix pacing]]")
        #expect(doc.elements[0].type == .action)
        #expect(doc.elements[0].text == "He walks away.")
        #expect(doc.elements[0].notes == ["fix pacing"])
    }

    @Test func forcedAction_withExclamation() {
        let doc = FountainParser.parse("!CUT TO:")
        #expect(doc.elements[0].type == .action)
        #expect(doc.elements[0].text == "CUT TO:")
    }
}

@Suite("FountainParser — round trip regressions")
struct FountainRoundTripRegressionTests {
    @Test func actionResemblingTransition_withNotes_staysActionOnRoundTrip() {
        let doc = FountainParser.parse("!CUT TO: [[fix this]]")
        #expect(doc.elements[0].type == .action)
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements[0].type == .action)
        #expect(reparsed.elements[0].text == "CUT TO:")
        #expect(reparsed.elements[0].notes == ["fix this"])
    }

    @Test func actionResemblingSceneHeading_withNotes_staysActionOnRoundTrip() {
        let doc = FountainParser.parse("!INT. HOUSE - DAY [[not a heading]]")
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements[0].type == .action)
        #expect(reparsed.elements[0].text == "INT. HOUSE - DAY")
    }

    @Test func centeredAction_withNotes_keepsNotesOnRoundTrip() {
        let doc = FountainParser.parse("> THE END < [[check placement]]")
        #expect(doc.elements[0].isCentered)
        #expect(doc.elements[0].notes == ["check placement"])
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements[0].isCentered)
        #expect(reparsed.elements[0].text == "THE END")
        #expect(reparsed.elements[0].notes == ["check placement"])
    }

    @Test func multilineNote_isExtracted() {
        let doc = FountainParser.parse("He walks away. [[fix pacing\nand tone]]")
        #expect(doc.elements[0].type == .action)
        #expect(doc.elements[0].text == "He walks away.")
        #expect(doc.elements[0].notes == ["fix pacing\nand tone"])
    }

    @Test func forcedTransition_withNotes_keepsNotesAndCleanText() {
        let doc = FountainParser.parse("> Burn to white. [[fix pacing]]")
        #expect(doc.elements[0].type == .transition)
        #expect(doc.elements[0].text == "Burn to white.")
        #expect(doc.elements[0].notes == ["fix pacing"])
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements[0].type == .transition)
        #expect(reparsed.elements[0].text == "Burn to white.")
        #expect(reparsed.elements[0].notes == ["fix pacing"])
    }

    @Test func standardTransition_withNotes_staysTransitionOnRoundTrip() {
        let doc = FountainParser.parse("> CUT TO: [[fix]]")
        #expect(doc.elements[0].type == .transition)
        #expect(doc.elements[0].text == "CUT TO:")
        #expect(doc.elements[0].notes == ["fix"])
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements[0].type == .transition)
        #expect(reparsed.elements[0].text == "CUT TO:")
        #expect(reparsed.elements[0].notes == ["fix"])
    }

    @Test func multilineAction_startingWithAllCapsName_staysActionOnRoundTrip() {
        let doc = FountainParser.parse("!JOHN\nSays hello without a colon.")
        #expect(doc.elements[0].type == .action)
        #expect(doc.elements[0].text == "JOHN\nSays hello without a colon.")
        let reparsed = FountainParser.parse(PlainTextExporter.export(doc))
        #expect(reparsed.elements.count == 1)
        #expect(reparsed.elements[0].type == .action)
        #expect(reparsed.elements[0].text == "JOHN\nSays hello without a colon.")
    }
}

@Suite("FountainParser — title page")
struct FountainTitlePageTests {
    @Test func titlePage_keyValuePairs() {
        let fountain = """
        Title: Big Fish
        Credit: written by
        Author: John August

        INT. HOUSE - DAY
        """
        let doc = FountainParser.parse(fountain)
        #expect(doc.titlePage.map(\.key) == ["Title", "Credit", "Author"])
        #expect(doc.titlePage[0].value == "Big Fish")
        #expect(doc.elements.first?.type == .sceneHeading)
    }

    @Test func titlePage_multilineIndentedValue() {
        let fountain = """
        Title:
            _**BRICK & STEEL**_
            _**FULL RETIRED**_
        Author: Stu Maschwitz

        FADE IN:
        """
        let doc = FountainParser.parse(fountain)
        #expect(doc.titlePage[0].key == "Title")
        #expect(doc.titlePage[0].value == "_**BRICK & STEEL**_\n_**FULL RETIRED**_")
    }

    @Test func documentWithoutTitlePage_startsAtElements() {
        let doc = FountainParser.parse("INT. HOUSE - DAY\n\nAction here.")
        #expect(doc.titlePage.isEmpty)
        #expect(doc.elements.count == 2)
    }

    @Test func titlePage_allowsArbitraryCustomKeys() {
        let fountain = """
        Title: Big Fish
        Producer: Jane Doe
        Author: John August

        INT. HOUSE - DAY
        """
        let doc = FountainParser.parse(fountain)
        #expect(doc.titlePage.map(\.key) == ["Title", "Producer", "Author"])
        #expect(doc.titlePage[1].value == "Jane Doe")
        #expect(doc.elements.first?.type == .sceneHeading)
    }

    @Test func bodyWithLeadingColon_isNotMistakenForTitlePage() {
        let doc = FountainParser.parse("Bob turns: he sees nothing.\n\nMore action.")
        #expect(doc.titlePage.isEmpty)
        #expect(doc.elements.map(\.type) == [.action, .action])
    }
}

@Suite("FountainParser — round trip (M0 exit criterion)")
struct FountainRoundTripTests {
    static let sample = """
    Title: The Sample
    Author: A. Writer

    FADE IN:

    INT. FILM SCHOOL - DAY

    A STUDENT types furiously on a laptop.

    STUDENT
    (muttering)
    Pagination has to be perfect.

    PROFESSOR (O.S.)
    Show me your blue pages!

    STUDENT
    Coming right up.

    CUT TO:

    EXT. CAMPUS - NIGHT

    The student walks home, exhausted but happy.

    > FADE OUT. <
    """

    @Test func parse_thenPlainText_isLossless() {
        let doc = FountainParser.parse(Self.sample)
        let dumped = PlainTextExporter.export(doc)
        let reparsed = FountainParser.parse(dumped)
        #expect(doc.elements.count == reparsed.elements.count)
        for (a, b) in zip(doc.elements, reparsed.elements) {
            #expect(a.type == b.type)
            #expect(a.text == b.text)
        }
        #expect(doc.titlePage.map(\.key) == reparsed.titlePage.map(\.key))
        #expect(doc.titlePage.map(\.value) == reparsed.titlePage.map(\.value))
    }

    @Test func parse_producesExpectedElementSequence() {
        let doc = FountainParser.parse(Self.sample)
        #expect(doc.elements.map(\.type) == [
            .action,         // FADE IN: (all-caps, not ending in TO:, blank line after)
            .sceneHeading,
            .action,
            .character, .parenthetical, .dialogue,
            .character, .dialogue,
            .character, .dialogue,
            .transition,
            .sceneHeading,
            .action,
            .action,         // centered FADE OUT.
        ])
    }
}
