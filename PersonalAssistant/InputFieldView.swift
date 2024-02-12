//
//  InputFieldView.swift
//  PDFChat
//
//  Created by 顾艳华 on 2023/11/23.
//

import SwiftUI

struct InputFieldView: View {
    
    @State private var isEditing = false
    @ObservedObject var viewModel: ViewModel
    @State private var searchText = ""
    var body: some View {
        HStack {
            ZStack(alignment: .leading){
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(height: 40)
                HStack {
                
                    TextField("个人助理..", text: $searchText, onEditingChanged: changedSearch)
                        .onSubmit {
                            Task {
                                await fetchSearch()
                            }
                        }
                        .textFieldStyle(.plain)
                        .padding()
                        .submitLabel(.send)
                    
                    if viewModel.searchText.count > 0 {
                        Button(action: clearSearch) {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .padding(.trailing, 8)
                        .foregroundColor(.gray)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .onChange(of: searchText) {
                viewModel.searchText = searchText
            }
            .onChange(of: viewModel.searchText) {
                searchText = viewModel.searchText
            }
        }
    }
    
    func changedSearch(isEditing: Bool) {
        self.isEditing = isEditing
    }
    
    func fetchSearch() async {
        guard !searchText.isEmpty else {
            return
        }
        await viewModel.invokeByQuestion(question: searchText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            clearSearch()
        }
    }
    
    func clearSearch() {
        searchText = ""
    }
}

#Preview {
    InputFieldView(viewModel: ViewModel())
}
