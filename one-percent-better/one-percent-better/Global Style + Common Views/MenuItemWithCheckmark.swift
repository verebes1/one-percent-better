//
//  MenuItemWithCheckmark.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/15/23.
//

import SwiftUI

struct MenuItemWithCheckmark<Value>: View where Value: Equatable {
    var value: Value
    
    /// This item will have a checkmark
    @Binding var selection: Value
    
    var body: some View {
        Button {
            selection = value
        } label: {
            if value == selection {
                Label(String(describing: value), systemImage: "checkmark")
            } else {
                Text(String(describing: value))
            }
        }
    }
}

struct MenuItemWithCheckmarks<Value>: View where Value: Equatable, Value: Hashable {
    var value: Value
    
    /// This item will have a checkmark
    @Binding var selections: [Value]
    
    var body: some View {
        Button {
            if let index = selections.firstIndex(of: value) {
                selections.remove(at: index)
            } else {
                selections.append(value)
            }
        } label: {
            if selections.contains(value) {
                Label(String(describing: value), systemImage: "checkmark")
            } else {
                Text(String(describing: value))
            }
        }
    }
}

struct MenuItemToggleCheckmark<Value>: View {
    var value: Value
    
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            if isSelected {
                Label(String(describing: value), systemImage: "checkmark")
            } else {
                Text(String(describing: value))
            }
        }
    }
}

struct MenuItemWithCheckmark_Previewer: View {
    
    @State private var selection = 0
    
    var body: some View {
        Menu("Select a number") {
            MenuItemWithCheckmark(value: 0, selection: $selection)
            MenuItemWithCheckmark(value: 1, selection: $selection)
            MenuItemWithCheckmark(value: 2, selection: $selection)
            MenuItemWithCheckmark(value: 3, selection: $selection)
        }
    }
}

struct MenuItemWithCheckmark_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemWithCheckmark_Previewer()
    }
}
