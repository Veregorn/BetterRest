//
//  ContentView.swift
//  BetterRest
//
//  Created by Rul-ex on 14/9/21.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    
    var body: some View {
        Stepper(value: $sleepAmount, in: 4...12) {
            Text("\(sleepAmount) hours")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
