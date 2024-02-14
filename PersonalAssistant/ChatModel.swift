//
//  Model.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/12/24.
//
import LangChain
import Foundation

struct ChatModel {
    var messages: [(String, String?)] = []
    let vc: SimilaritySearchKit
    let r: ParentDocumentRetriever
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1000.0
        sessionConfig.waitsForConnectivity = true
        let urlSession = URLSession(configuration: sessionConfig)
        
        let store = LocalFileStore()
        vc = SimilaritySearchKit(embeddings: OpenAIEmbeddings(session: urlSession), autoLoad: true)
        r = ParentDocumentRetriever(child_splitter: RecursiveCharacterTextSplitter(chunk_size: 400, chunk_overlap: 200), parent_splitter: RecursiveCharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200), vectorstore: vc, docstore: store)
    }
    func syncNotion() async -> [Document] {
        let l = NotionLoader()
        let docs = await l.load()
        // write notion to file
        
        // compare now and file
        
        return docs
    }
    
    func AddDocument(docs: [Document]) async {
        // remove old docs
        
        // add new docs
        await r.add_documents(documents: docs)
        vc.writeToFile()
    }
}
