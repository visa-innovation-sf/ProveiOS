//
//  ProveHomeViewModel.swift
//  ProveiOS
//
//  Created by Jayakumar Lalithambika, Vivek on 29/11/2021.
//

import Combine
import Foundation

protocol ProveHomeViewModelType: ObservableObject {
    var isTrustStore: Bool { get set }
    var selectedEnvironment: String { get set }
    var selectedCountry: String { get set }
    var countries: [String: String] { get }
    var phoneNumber: String { get set }
    var ipAddress: String { get set }
    var serverResponse: String? { get }
    var showLoader: Bool { get set }
    var redirectTargetURL: String? { get }
    var vfpToken: String? { get }
    var selectedCountryCode: String { get }

    func loadInitialData()
    func authenticateByRedirect()
    func validateVFPToken()
    func authenticateByRedirectFinish()
    func pingServer()
    func changeEnvironment()
    func setCountryCode()
    func loadIPAddress()
}

class ProveHomeViewModel: ProveHomeViewModelType {
    @Published var isTrustStore: Bool = false
    @Published var selectedEnvironment: String = ServerEnvironment.staging.rawValue
    @Published var phoneNumber: String = ""
    @Published var ipAddress: String = ""
    @Published private(set) var serverResponse: String? = nil

    @Published private(set) var redirectTargetURL: String? = nil
    @Published private(set) var vfpToken: String? = nil

    @Published var showLoader: Bool = false

    @Published var selectedCountry: String = "US"
    let countries = ["US": "+1", "Canada": "+1", "UK": "+44"]
    @Published private(set) var selectedCountryCode: String = "+1"

    private let ipProvider: IPAddressProviderProtocol
    private let apiClient: APIClientType

    private var subscribers = Set<AnyCancellable>()

    init(
        apiClient: APIClientType = Resolver.resolve(),
        ipProvider: IPAddressProviderProtocol = Resolver.resolve()
    ) {
        self.ipProvider = ipProvider
        self.apiClient = apiClient
    }

    func loadInitialData() {
        loadIPAddress()
    }

    func loadIPAddress() {
        showLoader = true
        let endpoint = ProveIPCheckEndpoint()
        apiClient.getData(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.showLoader = false
                    if case let .failure(error) = completion {
                        self?.serverResponse = error.errorDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.ipAddress = String(data: response, encoding: .utf8) ?? ""
                }
            ).store(in: &subscribers)
    }

    func authenticateByRedirect() {
        guard ipAddress.count > 0 else {
            serverResponse = "IP address not available"
            return
        }

        let start = CFAbsoluteTimeGetCurrent()
        showLoader = true
        var endpoint = AuthByRedirectEndpoint()
        endpoint.headers?["region"] = selectedCountry
        endpoint.headers?["environment"] = selectedEnvironment.lowercased()
        endpoint.payload?["DeviceIp"] = ipAddress
        //endpoint.payload?["DeviceIp"] = "166.137.217.20"
        endpoint.payload?["FinalTargetUrl"] = "https://vtsmap.digital.visa.com/VTSMAP/Test"
        endpoint.payload?["RequestId"] = UUID().uuidString

        apiClient.request(type: AuthenticateResponse.self, endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.showLoader = false
                    if case let .failure(error) = completion {
                        self?.serverResponse = error.errorDescription
                    }
                },
                receiveValue: { [weak self] data in
                    let diff = String(format: "%0.2f", CFAbsoluteTimeGetCurrent() - start)
                    self?
                        .serverResponse =
                    "\(data.description)\nResponse time: \(diff) seconds."
                    if let redirectTargetURL = data.response?.redirectTargetURL {
                        self?.redirectTargetURL = redirectTargetURL
                    }
                }
            ).store(in: &subscribers)
    }

    func validateVFPToken() {
        guard let redirectTargetURL = self.redirectTargetURL else { return }
        let start = CFAbsoluteTimeGetCurrent()
        showLoader = true
        var endpoint = VFSRedirectEndpoint()
        endpoint.path = redirectTargetURL

        apiClient.getURLResponse(endpoint: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.showLoader = false
                    if case let .failure(error) = completion {
                        self?.serverResponse = error.errorDescription
                    }
                },
                receiveValue: { [weak self] response in
                    let diff = String(format: "%0.2f", CFAbsoluteTimeGetCurrent() - start)
                    self?
                        .serverResponse =
                    "\(response)\nResponse time: \(diff) seconds"

                    if let url = response.url {
                        self?.vfpToken = url.getQueryParameter(param: "vfp")
                        print("VFP: \(self?.vfpToken ?? "No VFP Found")")
                    }
                }
            ).store(in: &subscribers)
    }

    func authenticateByRedirectFinish() {
        let start = CFAbsoluteTimeGetCurrent()
        showLoader = true

        var endpoint = AuthByRedirectFinishEndpoint()
        endpoint.headers?["region"] = selectedCountry
        endpoint.headers?["environment"] = selectedEnvironment.lowercased()
        endpoint.payload?["RequestId"] = UUID().uuidString
        endpoint
            .payload?["VerificationFingerprint"] = vfpToken

        apiClient.request(
            type: AuthenticateFinishResponse.self,
            endpoint: endpoint
        )
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.showLoader = false
                    if case let .failure(error) = completion {
                        self?.serverResponse = error.errorDescription
                    }
                },
                receiveValue: { [weak self] data in
                    let diff = String(format: "%0.2f", CFAbsoluteTimeGetCurrent() - start)
                    self?
                        .serverResponse =
                    "\(data.description)\nResponse time: \(diff) seconds."
                    self?.redirectTargetURL = nil
                    self?.vfpToken = nil
                }
            ).store(in: &subscribers)
    }

    func pingServer() {
        let start = CFAbsoluteTimeGetCurrent()
        showLoader = true
        apiClient.getData(endpoint: VTSMAPPingCheckEndpoint())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.showLoader = false
                        self?.serverResponse = error.errorDescription
                    }
                },
                receiveValue: { [weak self] data in
                    self?.showLoader = false
                    let diff = String(format: "%0.2f", CFAbsoluteTimeGetCurrent() - start)
                    self?
                        .serverResponse =
                    "\(String(decoding: data, as: UTF8.self))\nResponse time: \(diff) seconds"
                }
            ).store(in: &subscribers)
    }

    func changeEnvironment() {
        apiClient.change(environment: ServerEnvironment(rawValue: selectedEnvironment) ?? .staging)
    }

    func setCountryCode() {
        selectedCountryCode = countries[selectedCountry] ?? "+1"
    }
}

// For SwiftUI preview
class MockProveHomeViewModel: ProveHomeViewModelType {
    @Published var isTrustStore: Bool = false
    @Published var selectedEnvironment: String = ServerEnvironment.production.rawValue
    @Published var selectedCountry: String = "US"
    @Published var phoneNumber: String = ""
    var selectedCountryCode: String = "+1"
    @Published var ipAddress: String = ""
    @Published private(set) var serverResponse: String? = ""
    @Published private(set) var redirectTargetURL: String? = nil
    @Published private(set) var vfpToken: String? = nil

    @Published var showLoader: Bool = false
    let countries = ["US": "+1", "Canada": "+1", "UK": "+44"]

    @Injected var ipProvider: IPAddressProviderProtocol
    @Injected var apiClient: APIClientType

    func loadInitialData() {
        print("Initial Data called")
    }

    func authenticateByRedirect() {
        print("Authenticate by redirect called")
    }

    func authenticateByRedirectFinish() {
        print("Authenticate by Redirect finish called")
    }

    func pingServer() {
        print("Ping Server called")
    }

    func changeEnvironment() {
        print("Change environment called")
    }

    func validateVFPToken() {
        print("Validate called")
    }

    func setCountryCode() { }
    func loadIPAddress() {}
}
