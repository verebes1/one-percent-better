//
//  CreateNewHabit.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/17/22.
//

import SwiftUI

struct CreateNewHabit: View {
    
    @State private var habitName: String = ""
    
    var body: some View {
        ZStack {
            Color.backgroundGray
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                    .frame(height: 100)
                
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75)
                .foregroundColor(.green)
                
                Text("Create a New Habit")
                    .font(.system(size: 31))
                    .fontWeight(.bold)
                
                Text("Enter the name of your habit")
                
                Spacer()
                    .frame(height: 20)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(height: 50)
                    HStack {
                        Text("Name:")
                            .fontWeight(.semibold)
                            .padding(.leading, 10)
                        TextField("Habit Name", text: $habitName)
                    }
                }.padding(.horizontal, 15)
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.green)
                        .frame(height: 50)
                        .padding(.horizontal, 15)
                    Text("Next")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct CreateNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewHabit()
    }
}
