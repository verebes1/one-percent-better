//
//  EditTrackersList.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/24/22.
//

import SwiftUI

struct ListItem: Identifiable {
    var id = UUID()
    var index: Int
    var title: String
}

class ListViewModel: ObservableObject {
    @Published var items: [ListItem]
    
    init(items: [ListItem]) {
        self.items = items
    }
}

struct EditTrackersList: View {
    
    @ObservedObject var vm: ListViewModel
    @State private var itemOffsets: [CGFloat]
    @State private var rearrangeOffsets: [CGFloat]
    
//    private var dragGestures: [DragGesture]
    
    @State private var selectedIndex: Int? = nil
    
    var rowHeight: CGFloat = 50
    
    
    init() {
        let items = [
            ListItem(index: 0, title: "First"),
            ListItem(index: 1, title: "Second"),
            ListItem(index: 2, title: "Third"),
            ListItem(index: 3, title: "Fourth")
        ]
        vm = ListViewModel(items: items)
        self._itemOffsets = State.init(initialValue: Array<CGFloat>(repeating: 0, count: items.count))
        
        self._rearrangeOffsets = State.init(initialValue: Array<CGFloat>(repeating: 0, count: items.count))
        
//        self.dragGestures = Array<DragGesture>(repeating: DragGesture(), count: items.count)
    }
    
    func calculateRearrangeOffsets(index: Int, offset: CGFloat) -> [CGFloat] {
        var offsets: [CGFloat] = Array(repeating: 0, count: vm.items.count)
        let lowest = rowHeight / 2 - rowHeight * CGFloat(index)
        let highest = rowHeight / 2 + rowHeight * CGFloat(vm.items.count - 2 - index)
        var rowIndex = 0
        
        // This strides through difference in height between the selected row and all other rows. For example, if row 1 is selected out of 5 rows (indices 0,1,2,3,4), and the row height is 50, then this for loop is
        // (row: 0, diff: -25.0)
        // (row: 2, diff: 25.0)
        // (row: 3, diff: 75.0)
        // (row: 4, diff: 125.0)
        for diff in stride(from: lowest, through: highest, by: rowHeight) {
            if rowIndex == index {
                rowIndex += 1
            }
            
            if diff > 0 && offset > diff {
                offsets[rowIndex] -= rowHeight
            } else if diff < 0 && offset < diff {
                offsets[rowIndex] += rowHeight
            }
            rowIndex += 1
        }
        return offsets
    }
    
    func calculateNewIndices(index: Int) -> [Int] {
        var newIndices: [Int] = []
        for i in 0 ..< vm.items.count {
            newIndices.append(i)
        }

        var i = 0
        for diff in rearrangeOffsets {
            let moveBy = Int(diff) / 50
            newIndices[i] += moveBy
            i += 1
        }

        var missingIndex: Int?
        for i in 0 ..< newIndices.count {
            if !newIndices.contains(i) {
                missingIndex = i
                break
            }
        }
        if let missingIndex = missingIndex {
            newIndices[index] = missingIndex
        }
        print("newIndices: \(newIndices)")
        return newIndices
    }
    
    var body: some View {
        let longPress = LongPressGesture()
        
        Background {
            VStack(spacing: 0) {
                
                ForEach(0 ..< vm.items.count, id: \.self) { i in
                    HStack {
                        Text("off\t\(i):\t\(itemOffsets[i])")
                        Text("rearr\t\(i):\t\(rearrangeOffsets[i])")
                    }
                }
                
                ForEach(0 ..< vm.items.count, id: \.self) { i in
                    let isMoving = itemOffsets[i] != 0
//                    let _ = calculatedOffset(index: i)
                    EditTrackerRowMoveable(item: vm.items[i], rowHeight: rowHeight)
                        .offset(y: itemOffsets[i])
                        .offset(y: rearrangeOffsets[i])
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    itemOffsets[i] = value.translation.height
                                    
                                    withAnimation {
                                        rearrangeOffsets =  calculateRearrangeOffsets(index: i, offset: value.translation.height)
                                    }
                                }
                                .onEnded { _ in
                                    itemOffsets[i] = .zero
                                    let newIndices = calculateNewIndices(index: i)
                                    let copy = vm.items
                                    for i in 0 ..< vm.items.count {
                                        vm.items[i] = copy[newIndices.firstIndex(of: i)!]
                                    }
                                    for i in 0 ..< vm.items.count {
                                        vm.items[i].index = i
                                    }
                                    rearrangeOffsets = Array<CGFloat>(repeating: 0, count: vm.items.count)
                                }
                        
                        )
                        .zIndex(isMoving ? 1 : 0)
                        .shadow(color: .black.opacity(isMoving ? 0.5 : 0), radius: 5)
                    if i != vm.items.count - 1 {
                        Divider()
                    }
                }
                
            }
            .gesture(longPress)
//            .gesture(dragGesture)
            .padding(.horizontal, 20)
            .border(.black)
        }
    }
}

struct EditTrackersList_Previews: PreviewProvider {
    static var previews: some View {
        EditTrackersList()
    }
}


struct EditTrackerRow: View {
    
    @State private var offset = CGSize.zero
    @State private var isDragging: Bool = false
    
    
    @State private var rightMenuOffset: CGFloat = 0
    @State private var rightMenuOpen = false
    var rightMenuWidth: CGFloat = 70
    
    var size: CGFloat = 30
    
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
                if !rightMenuOpen {
                    rightMenuOffset = -offset.width
                } else {
                    rightMenuOffset = rightMenuWidth - offset.width
                }
            }
            .onEnded { _ in
                withAnimation {
                    if -offset.width > 50 {
                        rightMenuOpen = true
                        rightMenuOffset = rightMenuWidth
                    } else {
                        rightMenuOpen = false
                        rightMenuOffset = 0
                        offset = .zero
                    }
                }
                isDragging = false
            }
        
        ZStack {
            HStack {
                let margin: CGFloat = 20
                Spacer().frame(width: margin)
                Text("Tracker Name")
                    .offset(x: -rightMenuOffset)
                Spacer()
                EditHandle(size: 30)
                Spacer().frame(width: margin)
                
                Rectangle()
                    .fill(.red)
                    .frame(width: rightMenuOffset)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.cardColor)
            .gesture(dragGesture)
            
            let trashWidth: CGFloat = 23
            let rawTrashOffset = -rightMenuOffset + rightMenuWidth/2 + trashWidth/2
            let maxTrashOffset = -rightMenuWidth + rightMenuWidth/2 + trashWidth/2
            let trashOffset = rawTrashOffset < maxTrashOffset ? maxTrashOffset : rawTrashOffset
            
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: trashWidth)
                .offset(x: trashOffset)
                .foregroundColor(.white)
            }
        }
        .clipped()
    }
}

struct EditTrackerRowMoveable: View {
    
    @State private var offset = CGSize.zero
    
    @State private var longPressed: Bool = false
    
    var item: ListItem
    var rowHeight: CGFloat = 50
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                offset = .zero
                longPressed = false
            }
        
        let longPressGesture = LongPressGesture()
            .onEnded { value in
                longPressed = true
            }
        
        let combinedGestures = longPressGesture.sequenced(before: dragGesture).onChanged { value in
//            switch value {
//            case .second(true, let drag):
//                position = drag?.location ?? .zero
//            default:
//                break
//            }
        }
        
        ZStack {
            HStack {
                let margin: CGFloat = 20
                Spacer().frame(width: margin)
                Text("\(item.index): \(item.title)")
                Spacer()
                EditHandle(size: 30)
                Spacer().frame(width: margin)
            }
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
            .background(Color.cardColor)
//            .gesture(dragGesture)
//            .gesture(combinedGestures)
            
        }
        .clipped()
        
    }
}


struct EditHandle: View {
    var size: CGFloat = 200

    var body: some View {
        VStack(spacing: size/5.5) {
            RoundedRectangle(cornerRadius: size/5)
            .fill(Color.systemGray3)
            .frame(width: size, height: size/17)
            
            RoundedRectangle(cornerRadius: size/5)
            .fill(Color.systemGray3)
            .frame(width: size, height: size/17)
            
            RoundedRectangle(cornerRadius: size/5)
            .fill(Color.systemGray3)
            .frame(width: size, height: size/17)
        }
    }
}

struct EditHandle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 50) {
            EditHandle(size: 200)
            EditHandle(size: 100)
            EditHandle(size: 50)
            EditHandle(size: 30)
        }
    }
}
