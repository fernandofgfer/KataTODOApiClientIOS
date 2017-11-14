//
//  TODOAPIClientTests.swift
//  KataTODOAPIClient
//
//  Created by Pedro Vicente Gomez on 12/02/16.
//  Copyright © 2016 Karumi. All rights reserved.
//

import Foundation
import Nocilla
import Nimble
import XCTest
import Result
@testable import KataTODOAPIClient

class TODOAPIClientTests: NocillaTestCase {

    fileprivate let apiClient = TODOAPIClient()
    fileprivate let anyTask = TaskDTO(userId: "1", id: "2", title: "Finish this kata", completed: true)
    
    func testSendsContentTypeHeader() {
        let _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .withHeaders(["Content-Type": "application/json", "Accept": "application/json"])?
            .andReturn(200)

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result).toEventuallyNot(beNil())
    }

    func testParsesTasksProperlyGettingAllTheTasks() {
        let _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(200)?
            .withJsonBody(fromJsonFile("getTasksResponse"))

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.value?.count).toEventually(equal(200))
        assertTaskContainsExpectedValues(task: (result?.value?[0])!)
    }

    func testReturnsNetworkErrorIfThereIsNoConnectionGettingAllTasks() {
        stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andFailWithError(NSError.networkError())

        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }

        expect(result?.error).toEventually(equal(TODOAPIClientError.networkError))
    }
    
    func testReturnsUnkwonErrorIfThereIsUnknownErrorGettingAllTasks(){
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(414)
        
        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { response in
            result = response
        }
        
        expect(result?.error).toEventually(equal(TODOAPIClientError.unknownError(code: 414)))
    }
    
    func testReturnsItemNotFoundIfThereIsErrorGettingAllTasks(){
        _ = stubRequest("GET", "http://jsonplaceholder.typicode.com/todos")
            .andReturn(404)
    
        expect(self.getAll()?.error).toEventually(equal(TODOAPIClientError.itemNotFound))
    }
        
    
    
    private func getAll() -> Result<[TaskDTO], TODOAPIClientError>?{
        let networkCallDone = expectation(description: "asdsad")
        var result: Result<[TaskDTO], TODOAPIClientError>?
        apiClient.getAllTasks { (response) in
            result = response
            networkCallDone.fulfill()
        }
        wait(for: [networkCallDone], timeout: 2)
        return result
    }
    
    private func assertTaskContainsExpectedValues(task: TaskDTO) {
        expect(task.id).to(equal("1"))
        expect(task.userId).to(equal("1"))
        expect(task.title).to(equal("delectus aut autem"))
        expect(task.completed).to(beFalse())
    }
}
