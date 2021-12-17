//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Victor Colen on 17/12/21.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total is \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
                .padding()
            }
        }
        .alert("Thank you!", isPresented: $showingConfirmation) {
            Button("Ok") { }
        }  message: {
            Text(confirmationMessage)
        }
        .navigationTitle("Check out")
        .navigationBarTitleDisplayMode(.inline)
    }
    func placeOrder() async {
        guard let encoder = try? JSONEncoder().encode(order) else {
            print("Couldn't encode data")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoder)
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity)X \(Order.types[decodedOrder.type].lowercased()) cupcakes is on it's way!"
            showingConfirmation = true
        } catch {
            print("Checkout failed.")
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
