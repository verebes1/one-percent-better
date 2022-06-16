//
//  HabitCreationHeader.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI

struct HabitCreationHeader: View {
    
    let systemImage: String
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 65)
                .foregroundColor(.green)
            
            Text(title)
                .font(.system(size: 31))
                .fontWeight(.bold)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, 15)
    }
}

struct HabitCreationHeader_Previews: PreviewProvider {
    static var previews: some View {
        HabitCreationHeader(systemImage: "square.and.pencil", title: "Create New Habit", subtitle: "The lazy brown fox jumped over the moon, but how could the fox jump over the moon if he was lazy?")
    }
}
