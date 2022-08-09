//
//  ExerciseTrackerEntry.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

struct ExerciseTrackerEntry: View {
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        VStack {
            HStack {
                Text("Bench Press")
                    .fontWeight(.medium)
                    .padding(.leading, 20)
                Spacer()
            }
            
            LazyVGrid(columns: columns) {
                Text("Set")
                Text("Previous")
                Text("lbs")
                Text("Reps")
                Image(systemName: "checkmark")
            }
            
            LazyVGrid(columns: columns) {
                ForEach(0 ..< 4, id:\.self) { i in
                    Text(String(i+1))
                        .fontWeight(.medium)
                    PreviousWeight()
                    ExerciseField()
                    ExerciseField()
                    ExerciseCheckmark()
                }
            }
            .padding(.bottom, 10)
            
            ExerciseAddSet()
        }
    }
}

struct ExerciseTrackerEntry_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseTrackerEntry()
    }
}

struct PreviousWeight: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .foregroundColor(.systemGray5)
            .frame(width: 35, height: 3)
    }
}

struct ExerciseField: View {
    
    @State private var value: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
            
            TextField("", text: $value)
                .multilineTextAlignment(.center)
        }
        .frame(width: 60, height: 25)
    }
}

struct ExerciseCheckmark: View {
    
    @State private var completed: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(completed ? .systemGreen : .systemGray5)
                .frame(width: 35, height: 25)
            
            Image(systemName: "checkmark")
                .foregroundColor(completed ? .white : .black)
        }
        .onTapGesture {
            completed.toggle()
        }
    }
}

struct ExerciseAddSet: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.systemGray5)
                .frame(height: 25)
            Label("Add Set", systemImage: "plus")
                .font(.system(size: 14))
        }
        .padding(.horizontal, 18)
    }
}
