//
//  Model.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/12/24.
//
import LangChain
import Foundation
import SwiftUI

struct ChatModel {
    var updateMessage = "up to date"
    var updateMessageColor = Color.green
    var updateMessageTime = 1
    
    var messages: [(String, String?)] = []
    let fileStore = LocalFileStore(prefix: "notion")
    let vc: SimilaritySearchKit
    let r: ParentDocumentRetriever
    let p = RecursiveCharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200)
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 1000.0
        sessionConfig.waitsForConnectivity = true
        let urlSession = URLSession(configuration: sessionConfig)
        
        let store = LocalFileStore()
        vc = SimilaritySearchKit(embeddings: OpenAIEmbeddings(session: urlSession), autoLoad: true)
        r = ParentDocumentRetriever(child_splitter: RecursiveCharacterTextSplitter(chunk_size: 400, chunk_overlap: 200), parent_splitter: p, vectorstore: vc, docstore: store)
    }
    func syncNotion() async -> (toDelete:[Document], toAdd:[Document])? {
        let l = NotionLoader()
        var newDocs = await l.load()
        print("📒 Loaded notion \(newDocs.count)")
        if newDocs.isEmpty {
            return nil
        }
        newDocs = p.split_documents(documents: newDocs)
        
        // load file
        let ids = await fileStore.keys()
//        print("ids: \(ids)")
        let oldDocsContent = await fileStore.mget(keys: ids)
        var oldDocs = [Document]()
        for i in 0..<oldDocsContent.count {
            // set old id
            oldDocs.append(Document(page_content: oldDocsContent[i], metadata: ["id": ids[i]]))
        }
        let todo = compareStringArrays(oldArray: oldDocs, newArray: newDocs)
        print("✅ todo: add \(todo.toAdd.count) remove \(todo.toDelete.count)")
        // compare new and file
      
        return (todo.toDelete, todo.toAdd )
    }
    
    func AddDocument(docs: (toDelete:[Document], toAdd:[Document])) async {
        // remove old docs
        await r.remove_documents(documents: docs.toDelete)
        // add new docs
        let ids = await r.add_documents(documents: docs.toAdd)
        // write notion with id to file
        
        var notionWithId = [(String, String)]()
        for i in 0..<ids.count {
            notionWithId.append((ids[i], docs.toAdd[i].page_content))
        }
        // add by id
        await fileStore.mset(kvpairs: notionWithId)
        // remove by id
        await fileStore.mdelete(keys: docs.toDelete.map{$0.metadata["id"]!})
        vc.writeToFile()
    }
    
    func compareStringArrays(oldArray: [Document], newArray: [Document]) -> (toDelete: [Document],
  toAdd: [Document]) {
        let toDelete = oldArray.filter { !newArray.contains($0) }
        let toAdd = newArray.filter { !oldArray.contains($0) }

        return (toDelete, toAdd)
    }
}
