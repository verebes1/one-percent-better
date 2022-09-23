//
//  ImageTrackerEnterDataView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/17/22.
//

import SwiftUI

struct ImageTrackerEnterDataView: View {
    
    var name: String
    @Binding var image: UIImage
    
    @State private var showSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .onTapGesture {
                        showSheet = true
                    }
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .sheet(isPresented: $showSheet) {
                // Pick an image from the photo library:
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                
                //  If you wish to take a photo from camera instead:
                // ImagePicker(sourceType: .camera, selectedImage: self.$image)
            }
        }
    }
}

struct ImageTrackerEnterDataView_Previews: PreviewProvider {
    
    @State static var image = UIImage(systemName: "photo.on.rectangle")!
    
    static var previews: some View {
        Background {
            CardView {
                ImageTrackerEnterDataView(name: "Swimming", image: $image)
            }
        }
    }
}
