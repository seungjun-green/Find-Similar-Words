//
//  ContentView.swift
//  SW
//
//  Created by SeungJun Lee on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var inputWord: String = ""
    @State private var similarWords: [String] = []
    @State private var isLoading: Bool = false
    @State private var showingWords: Int = 10
    @State private var showInfo = false
    
    let modelManager = ModelManager()
    
    
    var disableButton: Bool {
        return inputWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let helper = Helper()
    
    @StateObject private var viewModel = AppViewModel()
        
    
    var body: some View {
        Group {
            if viewModel.isInitializing {
                
                VStack{
                    
                    HStack{
                        Text("Loading word data").font(.title2)
                        
                        ProgressView().progressViewStyle(.circular).font(.title2)
                    }
                   
                    
                    Text("Thank you for your patience.")
                }
                
            } else {
                NavigationStack {
                    
                    VStack {
                        
                        TextField("Enter a word", text: $inputWord)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                        
                        
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            
                        } else {
                            Button("Find Similar Words") {
                                isLoading = true
                                showingWords = 10
                                dismissKeyboard()
                                
                                similarWords = [String]()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    similarWords = modelManager.predict(input: inputWord.lowercased())
                                    isLoading = false
                                }
                                
                                
                            }
                            .disabled(disableButton)
                            .padding()
                            .foregroundColor(.white)
                            .background(disableButton ? Color.blue.opacity(0.7) : Color.blue)
                            .cornerRadius(10)
                        }
                        
                        
                        ScrollViewReader { proxy in
                            
                            List{
                                ForEach(similarWords.prefix(showingWords), id: \.self) { word in
                                    Text(word).id(word)
                                }
                                
                                Text("Last Element")
                                    .listRowSeparator(.hidden, edges: [.bottom])
                                    .opacity(0.0004)
                                    .id("last")
                                
                            }.listStyle(.plain)
                                .textSelection(.enabled)
                                .onAppear{
                                    withAnimation {
                                        proxy.scrollTo("last", anchor: .bottom)
                                    }
                                    
                                    
                                }.onChange(of: showingWords) { oldValue, newValue in
                                    withAnimation {
                                        proxy.scrollTo("last", anchor: .bottom)
                                    }
                                    
                                }
                                .toolbar {
                                    
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button(action: {
                                            showInfo.toggle()
                                        }, label: {
                                            Image(systemName: "info.circle")
                                        }).popover(isPresented: $showInfo, content: {
                                            Text("The most similar words are shown at the top of the list.")
                                        })
                                    }
                                    
                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button(action: {
                                            similarWords = [String]()
                                            showingWords = 10
                                            inputWord = ""
                                        }, label: {
                                            Text("Clear")
                                        })
                                    }
                                    
                                    
                                    
                                    
                                }
                            
                            
                            
                            
                            
                            if similarWords.count > 1 {
                                Button(action: {
                                    
                                    if showingWords < 100 {
                                        showingWords += 10
                                        
                                    }
                                    
                                }, label: {
                                    if showingWords < 100 {
                                        Text("Show More")
                                    } else {
                                        Text("You reached the end.").foregroundColor(.primary)
                                    }
                                    
                                })
                            }
                        }
                        
                    }
                    
                    .navigationTitle("Similar Words Finder")
                }
            }
        }.onAppear {
            viewModel.initializeModelManager()
        }
    }
    
    private func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}
