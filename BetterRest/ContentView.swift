//
//  ContentView.swift
//  BetterRest
//
//  Created by Rul-ex on 14/9/21.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = Date()
    @State private var coffeeAmount = 1
    // I'm going to use an alert in order to show the result of the prediction then I need this 3 vars
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g") hours")
                }
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(value: $coffeeAmount, in: 1...20) {
                    if coffeeAmount == 1 {
                        Text("1 cup")
                    } else {
                        Text("\(coffeeAmount) cups")
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedTime) {
                    Text("Calculate")
                }
            )
            // I need to add a modifier in the 'VStack' in order to show the alert message
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func calculateBedTime() {
        // Loaded our Core ML model into XCode. It automatically generates a class with the name of the file (SleepCalculator in this case). We are going to create an instance of that class
        let model = SleepCalculator()
        // We need to extract hours and minutes from wakeUp Date() type variable (because the model works with seconds). 'DateComponents' is our friend
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        // Calculating the number of seconds in wakeUP's variable (hour part)
        let hour = (components.hour ?? 0) * 60 * 60
        // Calculating the number of seconds in wakeUP's variable (minute part)
        let minute = (components.minute ?? 0) * 60
        // The next step is to feed our values into Core ML and see what comes out
        // We need to use 'do' and 'catch' because Core ML could fail
        do {
            // 'SleepCalculator' class has a method named 'prediction' and we need to feed it with all the input vars in our model
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            // Now we have the output in 'prediction.actualSleep', but that's a value in seconds and users need the time they should go to bed. Then we can substract it from the time they need to wake up. Fortunatelly if I substract a number of seconds from a Date(), I have a new Date(). Good
            let sleepTime = wakeUp - prediction.actualSleep
            // Now I need to convert this Date() in a good 'String' for the user to show it in the Alert message. 'DateFormatter' is our friend
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            // Now the messages
            alertTitle = "Your ideal bedtime is..."
            alertMessage = formatter.string(from: sleepTime)
        } catch {
            // If something went wrong
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        // I need to show the alert regardless of whether or not the prediction worked
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
