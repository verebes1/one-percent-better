//
//  CustomToolbarView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/18/22.
//
/*
import SwiftUI

struct CustomToolbarView: View {
    
    let toolbarHeight: CGFloat
    @State var isPresenting: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                BlurView(style: .regular)
//                            .frame(height: toolbarHeight)
                    .ignoresSafeArea()
                
                HStack {
                    EditButton()
                    Spacer()
                    Text("Toolbar")
                    Spacer()
                    NavigationLink(
                        destination: ChooseHabitName(),
                        isActive: $isPresenting) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 23)
                        }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
//                    .background(.blue)
            Spacer()
        }
    }
}

struct CustomToolbarView_Previews: PreviewProvider {
    
    
    static let toolbarHeight: CGFloat = 100
    
    static var previews: some View {
        NavigationView {
            Background {
                ZStack {
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: toolbarHeight)
                            ForEach(0 ..< 30, id: \.self) { i in
                                VStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .frame(height: 50)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    List {
                        Section {
                            ForEach(0 ..< 30, id: \.self) { i in
                                Text("Hello \(i)")
                                    .background(.red)
                            }
                        } header: {
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    CustomToolbarView(toolbarHeight: toolbarHeight)
                }
            }
            
            .navigationBarHidden(true)
        }
    }
}
*/
