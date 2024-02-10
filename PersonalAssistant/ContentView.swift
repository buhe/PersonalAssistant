//
//  ContentView.swift
//  PersonalAssistant
//
//  Created by 顾艳华 on 2/10/24.
//

import SwiftUI
import CoreData
import LangChain
import OpenAIKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    init() {
        Task {
            let l = NotionLoader()
            let docs = await l.load()
            let llm = OpenAI(model: Model.GPT4.gpt4_1106_preview)
            let store = LocalFileStore()
            let r = await ParentDocumentRetriever(child_splitter: RecursiveCharacterTextSplitter(chunk_size: 400, chunk_overlap: 200), parent_splitter: RecursiveCharacterTextSplitter(chunk_size: 2000, chunk_overlap: 200), vectorstore: SimilaritySearchKit(embeddings: OpenAIEmbeddings()), docstore: store)

            await r.add_documents(documents: docs)
            
            let qa = ConversationalRetrievalChain(retriver: r, llm: llm)
            var chat_history:[(String, String)] = []
            let question = "最后和谁结婚了？"
            let result = await qa.predict(args: ["question": question, "chat_history": ConversationalRetrievalChain.get_chat_history(chat_history: chat_history)])
            chat_history.append((question, result!.0))
            
            print("⚠️**Question**: \(question)")
            print("✅**Answer**: \(result!)")
        }
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
