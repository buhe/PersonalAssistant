//
//  ViewModel.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/12/24.
//
import LangChain
import OpenAIKit
import NIOPosix
import NIOCore
import AsyncHTTPClient
import Foundation

class ViewModel: ObservableObject {
    @Published var model: ChatModel
    @Published var searchText = ""
    
    @Published var isLoading = false
    @Published var loadingText = ""
    
    var chat_history:[(String, String)] = []
    init() {
        model = ChatModel()
    }
    func syncData() async {
        DispatchQueue.main.async {
             self.isLoading = true
             self.loadingText = "Loading Notion..."
        }
        let docs = await model.syncNotion()
        if let docs = docs {
            if !docs.toAdd.isEmpty || !docs.toDelete.isEmpty {
                await model.AddDocument(docs: docs)
            }
            print("🚗 Loaded added \(docs.toAdd.count) and deleted \(docs.toDelete.count)")
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func invokeByQuestion(question: String) async {
        DispatchQueue.main.async {
            self.model.messages.append((question,nil))
        }

        let llm = OpenAI(model: Model.GPT4.gpt4_1106_preview)
        
        let qa = ConversationalRetrievalChain(retriver: model.r, llm: llm)
//        await syncData()
        let result = await qa.predict(args: ["question": question, "chat_history": ConversationalRetrievalChain.get_chat_history(chat_history: chat_history)])
//        chat_history.append((question, result!.0))
        
        print("⚠️**Question**: \(question)")
        print("✅**Answer**: \(result!)")
        DispatchQueue.main.async {
            let found = self.model.messages.filter { $0.0 == question }
            self.model.messages.removeAll { $0.0 == question }
            if var first = found.first {
                first.1 = result!.0 + "\n>> " + (result!.1 ?? "")
                self.model.messages.append(first)
            }
            
        }
    }
    

}
