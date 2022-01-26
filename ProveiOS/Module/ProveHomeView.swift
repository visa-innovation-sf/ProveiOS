//
//  ContentView.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 16/11/2021.
//

import SwiftUI

struct ProveHomeView<VM>: View where VM: ProveHomeViewModelType {
    @ObservedObject var viewModel: VM

    var body: some View {
        NavigationView {
            Form {
                options
                sections
                response
            }.padding(-5)
                .modifier(DismissingKeyboard())
                .font(.system(size: 13))
                .accentColor(Color(ColorNames.visaBlue.rawValue))
                .progressDialog(
                    isShowing: $viewModel.showLoader,
                    message: "Updating..."
                )
                .navigationBarTitle("Prove POC", displayMode: .inline)
                .onAppear {
                    viewModel.loadInitialData()
                }
                .toolbar {

                    ToolbarItem(placement: .navigation) {
                        Button(action: {
                            viewModel.loadIPAddress()

                        }) {
                            Image(systemName: "arrow.clockwise.circle")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                        }
                    }
                }
        }.navigationBarColor(
            backgroundColor: UIColor(
                named: ColorNames.visaBlue.rawValue
            ) ?? .blue,
            tintColor: UIColor(
                named: ColorNames.navTextColor.rawValue
            ) ?? .systemGray6
        )
    }
}

extension ProveHomeView {
    var options: some View {
        Section(header: Text("Options")) {
            Picker("Environment", selection: $viewModel.selectedEnvironment) {
                ForEach(ServerEnvironment.allCases) {
                    Text($0.rawValue)
                }
            }.onChange(of: viewModel.selectedEnvironment) { _ in
                viewModel.changeEnvironment()
            }

            Toggle("US Trust Store", isOn: $viewModel.isTrustStore)
                .toggleStyle(CheckboxStyle())

            Picker("Country", selection: $viewModel.selectedCountry) {
                ForEach(Array(viewModel.countries.keys), id: \.self) {
                    Text($0)
                }
            }.onChange(of: viewModel.selectedCountry) { _ in
                viewModel.setCountryCode()
            }

            HStack {
                Text("IP Address")
                Spacer()
                TextField("", text: $viewModel.ipAddress)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }

            HStack {
                Text(viewModel.selectedCountryCode)
                Divider()
                Spacer()
                TextField("Phone Number (Optional)", text: $viewModel.phoneNumber)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.phonePad)
            }
        }
    }

    var sections: some View {
        Section(header: Text("Requests")) {
            Button(action: {
                viewModel.authenticateByRedirect()
            }) {
                HStack {
                    Spacer()
                    Text("Auth By Redirect")
                    Spacer()
                }
            }
            .buttonStyle(OutlineButtonStyle())
            .padding(.top, 5)

            Button(action: {
                viewModel.validateVFPToken()
            }) {
                HStack {
                    Spacer()
                    Text("Get VFP")
                    Spacer()
                }
            }
            .buttonStyle(OutlineButtonStyle())
            .disabled(viewModel.redirectTargetURL == nil)
            .padding(.top, 5)

            Button(action: {
                viewModel.authenticateByRedirectFinish()
            }) {
                HStack {
                    Spacer()
                    Text("Auth By Redirect Finish")
                    Spacer()
                }
            }
            .buttonStyle(OutlineButtonStyle())
            .disabled(viewModel.vfpToken == nil)
            .padding(.top, 5)

            Button(action: {
                viewModel.pingServer()
            }) {
                HStack {
                    Spacer()
                    Text("Ping Server")
                    Spacer()
                }
            }
            .buttonStyle(OutlineButtonStyle())
            .padding(.bottom, 5)
        }
    }

    var response: some View {
        Section(header: Text("Response")) {
            Text(viewModel.serverResponse ?? "")
                .font(.system(size: 12))
                .padding(3)
        }
    }
}

struct ProveHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ProveHomeView(viewModel: MockProveHomeViewModel())
    }
}
