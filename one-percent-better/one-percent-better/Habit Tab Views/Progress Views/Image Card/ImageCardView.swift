//
//  ImageCardView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/15/22.
//

import SwiftUI


class ImageCardViewModel: ObservableObject {
    
    @ObservedObject var imageTracker: ImageTracker
    
    var images: [UIImage] = []
    var previewImages: [UIImage] = []
    let maxImages = 15
    
    
    init(imageTracker: ImageTracker) {
        self.imageTracker = imageTracker
        self.images = imageTracker.values.map { data in
            UIImage(data: data)!
        }
        self.previewImages = self.images
        let toDrop = images.count - maxImages
        if toDrop > 0 {
            self.previewImages = Array(images.dropFirst(toDrop))
        }
    }
    
    func loadImages(images: [UIImage]) {
        self.images = images
        self.previewImages = images
        let toDrop = images.count - maxImages
        if toDrop > 0 {
            self.previewImages = Array(images.dropFirst(toDrop))
        }
    }
}

struct ImageCardView: View {
    
    var vm: ImageCardViewModel
    
    let photoSpacing: CGFloat = 4
    var gridItem: GridItem {
        .init(.flexible(), spacing: photoSpacing)
    }
    var columns: [GridItem] {
        Array(repeating: gridItem, count: 5)
    }
    
    var body: some View {
        CardView {
            VStack {
                SimpleCardTitle(vm.imageTracker.name) {
                    NavigationLink("View All", destination: AllImagesView(images: vm.images))
                }
                
                LazyVGrid(columns: columns, alignment: .center, spacing: photoSpacing) {
                    ForEach(0 ..< vm.previewImages.count, id: \.self) { i in
                        
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(uiImage: vm.previewImages[i])
                                    .resizable()
                                    .scaledToFill()
                                )
                            .clipShape(Rectangle())
                    }
                }
                .padding(.horizontal, photoSpacing)
            }
        }
    }
}

struct ImageCardView_Previews: PreviewProvider {
    
    static func data() -> ImageTracker {
        let context = CoreDataManager.previews.mainContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = ImageTracker(context: context, habit: h1, name: "Laps")
            
            let patioBefore = UIImage(named: "patio-before")!
            var day = day1
            for _ in 0 ..< 7 {
                t1.add(date: day, value: patioBefore)
                day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
            }
            t1.add(date: day0, value: UIImage(named: "patio-done")!)
        }
        
        let habits = Habit.habits(from: context)
        let habit = habits.first!
        let tracker = habit.trackers.firstObject as! ImageTracker
        return tracker
    }
    
    static var previews: some View {
        let imageTracker = data()
        let vm = ImageCardViewModel(imageTracker: imageTracker)
        
        let patio = UIImage(named: "patio-done")!
        let patioImages = Array<UIImage>(repeating: patio, count: 20)
        let _ = vm.loadImages(images: patioImages)
        
        NavigationView {
            Background {
                ImageCardView(vm: vm)
            }
        }
    }
}
