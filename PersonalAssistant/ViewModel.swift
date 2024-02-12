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
    
    init() {
        model = ChatModel()
    }
    
    func invokeByQuestion(question: String) async {
        DispatchQueue.main.async {
            self.model.messages.append((question,nil))
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1000.0
        sessionConfig.waitsForConnectivity = true
        let urlSession = URLSession(configuration: sessionConfig)
        
        let l = NotionLoader()
        let docs = await l.load()
        let llm = OpenAI(model: Model.GPT4.gpt4_1106_preview)
        let store = LocalFileStore()
        let r = await ParentDocumentRetriever(child_splitter: RecursiveCharacterTextSplitter(chunk_size: 400, chunk_overlap: 200), parent_splitter: RecursiveCharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200), vectorstore: SimilaritySearchKit(embeddings: OpenAIEmbeddings(session: urlSession)), docstore: store)

        await r.add_documents(documents: docs)
        
        let qa = ConversationalRetrievalChain(retriver: r, llm: llm)
        var chat_history:[(String, String)] = []
        let result = await qa.predict(args: ["question": question, "chat_history": ConversationalRetrievalChain.get_chat_history(chat_history: chat_history)])
        chat_history.append((question, result!.0))
        
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
