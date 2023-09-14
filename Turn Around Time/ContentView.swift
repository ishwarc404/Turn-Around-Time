//
//  ContentView.swift
//  Turn Around Time
//
//  Created by Ishwar Choudhary on 9/14/23.
//

import SwiftUI


struct ContentView: View {
    
    @State private var selectedStartTime = Date()
    @State private var selectedEndTime = Date()
    @State private var travelDistance = Double()
    @State private var travelDistanceInput = ""
    @State private var paceInput = ""
    @State private var calculatedTurnAroundTime = ""
    @State private var unitSelection = 0 // 0 represents miles, 1 represents kilometers
    @State private var calculatedPaceToMatch = ""

    
    @State private var startTimeSelected = false
    @State private var endTimeSelected = false
    @State private var travelDistanceInputSelected = false
    @State private var paceInputSelected = false
    
    
    var body: some View {
        VStack {
            Text("Let's find your turn around time and pace you need to maintain for your next hike!")
                .multilineTextAlignment(.center)
                .font(.title3) // Adjust the font size and style here
                .foregroundColor(.secondary) // Adjust the text color here
                .padding()
            
            DatePicker(
                "Start time",
                selection: $selectedStartTime,
                displayedComponents: [.hourAndMinute]
            ).padding()
                .onChange(of: selectedStartTime) {
                    startTimeSelected = true
                    calculateTurnAroundTime()
                }
            
            DatePicker(
                "Get back by time",
                selection: $selectedEndTime,
                in: Calendar.current.date(byAdding: .minute, value: 1, to: selectedStartTime)!...,
                displayedComponents: [.hourAndMinute]
            ).padding()
                .onChange(of: selectedEndTime) {
                    endTimeSelected = true
                    calculateTurnAroundTime()
                }
            
            TextField("Enter one-way travel distance", text: $travelDistanceInput)
                .textFieldStyle(.roundedBorder)
                .padding()
                .keyboardType(.decimalPad) // Set the keyboardType to .decimalPad
                .onChange(of: travelDistanceInput) {
                    travelDistanceInputSelected = true
                    calculateTurnAroundTime()
                }
                .onTapGesture { // Add onTapGesture to dismiss the keyboard when tapped outside
                    UIApplication.shared.endEditing()
                }
            
//            TextField("Enter pace, distance per hour", text: $paceInput)
//                .textFieldStyle(.roundedBorder)
//                .padding()
//                .keyboardType(.decimalPad) // Set the keyboardType to .decimalPad
//                .onChange(of: paceInput) {
//                    paceInputSelected = true
//                    calculateTurnAroundTime()
//                }
            
            Picker("Select Unit", selection: $unitSelection) {
                    Text("Miles").tag(0)
                    Text("Kilometers").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: unitSelection) {
                    calculateTurnAroundTime()
                }
                .padding()
            
            if !calculatedTurnAroundTime.isEmpty {
                Text("Your turn around time will be:").padding()
                Text(calculatedTurnAroundTime).padding()
            }
            
            Spacer() // Occupies the same space when calculatedTurnAroundTime is hidden
            
            
            if !calculatedPaceToMatch.isEmpty {
                Text("Your pace to reach your destination and come back on time will be:")
                    .multilineTextAlignment(.center).padding()
                Text(calculatedPaceToMatch).padding()
            }
            
            Spacer() // Occupies the same space when calculatedTurnAroundTime is hidden
        }
        .padding()
    }
    
    private func calculateTurnAroundTime() {
        // Check if all fields are fully entered and valid
        if endTimeSelected && !travelDistanceInput.isEmpty && Double(travelDistanceInput) != nil {
            
            // Convert the inputs to appropriate data types
            let travelDistance = Double(travelDistanceInput) ?? 0.0
            let pace = Double(paceInput) ?? 0.0
            
            // Calculate the time it would take to reach the destination at the given pace in hours
            let travelTimeHours = travelDistance / pace
            
            // Convert the selected start and end times to Calendar components
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: selectedStartTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: selectedEndTime)
            
            // Calculate the total time available for the trip in hours
            let totalHoursAvailable = Double(endComponents.hour! - startComponents.hour!) + Double(endComponents.minute! - startComponents.minute!) / 60.0
            
//            print("Total hours availabel \(totalHoursAvailable)")

            // Calculate the turnaround time
            let turnaroundTimeHours = totalHoursAvailable / 2.0 // Assumes turning around halfway through the available time
            
//            print("Calculated pace: \(travelDistance / turnaroundTimeHours)")
            calculatedPaceToMatch = String((travelDistance / turnaroundTimeHours).rounded()) + (unitSelection == 0 ? " Miles / Hour" : " Kilometers / Hour")

            
//            print("Turn around time after these many  hours \(turnaroundTimeHours)")
            let turnaroundTime = calendar.date(byAdding: .minute, value: Int(turnaroundTimeHours * 60), to: selectedStartTime)

            // Update calculatedTurnAroundTime based on the calculated time
            if let turnaroundTime = turnaroundTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                calculatedTurnAroundTime = dateFormatter.string(from: turnaroundTime)
            }
        }
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
    
#Preview {
    ContentView()
}
