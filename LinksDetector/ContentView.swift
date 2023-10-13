//
//  ContentView.swift
//  LinksDetector
//
//  Created by e.pospelova on 13.10.2023.
//
import SwiftUI
import UIKit


struct ContentView: View {
    var body: some View {
        LinkTextView("Visit our bestdoctor://call/ambulancewebsite at https://www.example.com or call us at +1 (123) 456-7890 or email us at contact@example.com.")
            .padding()
    }
}

struct LinkTextView: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        attributedText(string: text).accentColor(.red)
    }

    func attributedText(string: String) -> Text {
         guard
             let linkDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
             let phoneDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
         else { return Text(LocalizedStringKey(string)) }

         let stringRange = NSRange(location: 0, length: string.count)
         let linkMatches = linkDetector.matches(in: string, options: [], range: stringRange)
         let phoneMatches = phoneDetector.matches(in: string, options: [], range: stringRange)

         let attributedString = NSMutableAttributedString(string: string)
         for match in linkMatches {
             attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single, range: match.range)
         }
         for match in phoneMatches {
             attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single, range: match.range)
         }
         var mainText = Text("")
         attributedString.enumerateAttributes(in: stringRange, options: []) { attrs, range, _ in
             var slice: Text = Text(LocalizedStringKey(attributedString.attributedSubstring(from: range).string))

             if attrs[.underlineStyle] != nil {
                 let stringSlice = attributedString.attributedSubstring(from: range).string
                 var markDownLinkString = ""
                 if isValidEmail(stringSlice) {
                     markDownLinkString = "[\(stringSlice)](mailto:\(stringSlice))"
                 } else {
                     markDownLinkString = "[\(stringSlice)](\(stringSlice))"
                 }
                 slice = Text(.init(markDownLinkString)).underline()

             } else if attrs[.strikethroughStyle] != nil {
                 let phone = attributedString.attributedSubstring(from: range).string
                 let cleanedPhoneNumber = phone.replacingOccurrences(of: "[^0-9,+]", with: "", options: .regularExpression)
                 let markDownLinkString = "[\(phone)](tel:\(cleanedPhoneNumber))"
                 slice = Text(.init(markDownLinkString)).underline()
             }
             mainText = mainText + slice
         }
         return mainText
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
