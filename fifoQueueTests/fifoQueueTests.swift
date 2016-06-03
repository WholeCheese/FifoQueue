//
//  fifoQueueTests.swift
//  fifoQueueTests
//
//  Created by Allan Hoeltje on 5/8/16.
//  Copyright © 2016 Allan Hoeltje. All rights reserved.
//

import XCTest
@testable import fifoQueue

class fifoQueueTests: XCTestCase
{
    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample()
	{
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample()
	{
        // This is an example of a performance test case.
        self.measureBlock
		{
            // Put the code you want to measure the time of here.
        }
    }

	func testAdd1ToQueue()
	{
		let qTest = Queue<String>()
		qTest.enqueue("1")
	}
	
	func testAddSeveralToQueue()
	{
		let qTest = Queue<String>()
		XCTAssert(qTest.isEmpty())
		qTest.enqueue("1")
		qTest.enqueue("1")
		XCTAssertFalse(qTest.isEmpty())
		qTest.enqueue("1")
		qTest.enqueue("1")
		qTest.enqueue("1")
	}
	
	func testRemoveOne()
	{
		let qTest = Queue<String>()
		qTest.enqueue("1")
		qTest.enqueue("")
		qTest.enqueue("")
		qTest.enqueue("")
		let thefirstone = qTest.dequeue()
		
		XCTAssertNotNil(thefirstone)
		XCTAssertEqual(thefirstone!, "1")
	}
	
	func testRemoveAll()
	{
		let qTest = Queue<String>()
		qTest.enqueue("1")
		qTest.enqueue("2")
		qTest.enqueue("3")
		qTest.enqueue("4")
		
		XCTAssertEqual(qTest.dequeue()!, "1")
		XCTAssertEqual(qTest.dequeue()!, "2")
		XCTAssertEqual(qTest.dequeue()!, "3")
		XCTAssertEqual(qTest.dequeue()!, "4")
		XCTAssert(qTest.isEmpty())
		XCTAssertNil(qTest.dequeue())
		XCTAssertNil(qTest.dequeue())
		XCTAssert(qTest.isEmpty())
	}
	
	func testGenerics()
	{
		let qTest = Queue<Int>()
		qTest.enqueue(1)
		qTest.enqueue(2)
		qTest.enqueue(3)
		qTest.enqueue(4)
		
		XCTAssertEqual(qTest.dequeue()!, 1)
		XCTAssertEqual(qTest.dequeue()!, 2)
		XCTAssertEqual(qTest.dequeue()!, 3)
		XCTAssertEqual(qTest.dequeue()!, 4)
	}
	
	func  testAddNil()
	{
		let qTest = Queue<Int?>()
		qTest.enqueue(nil)
		if let node = qTest.dequeue()
		{
			XCTAssertNil(node)
		}
		
		qTest.enqueue(2)
		qTest.enqueue(nil)
		qTest.enqueue(4)
		
		XCTAssertEqual(qTest.dequeue()!, 2)
		//	XCTAssertEqual(qTest.dequeue()!!, 2)

		if let node = qTest.dequeue()
		{
			XCTAssertNil(node)
		}

		XCTAssertEqual(qTest.dequeue()!, 4)
		//	XCTAssertEqual(qTest.dequeue()!!, 4)
	}
	
	func testAddAfterEmpty()
	{
		let qTest = Queue<String>()
		
		qTest.enqueue("1")
		XCTAssertEqual(qTest.dequeue()!, "1")
		XCTAssertNil(qTest.dequeue())
		
		qTest.enqueue("1")
		qTest.enqueue("2")
		XCTAssertEqual(qTest.dequeue()!, "1")
		XCTAssertEqual(qTest.dequeue()!, "2")
		XCTAssert(qTest.isEmpty())
		XCTAssertNil(qTest.dequeue())
	}
	
	func testAddAndRemoveChaotically()
	{
		let qTest = Queue<String>()
		
		qTest.enqueue("1")
		XCTAssertFalse(qTest.isEmpty())
		XCTAssertEqual(qTest.dequeue()!, "1")
		XCTAssert(qTest.isEmpty())
		XCTAssertNil(qTest.dequeue())
		
		qTest.enqueue("1")
		qTest.enqueue("2")
		XCTAssertEqual(qTest.dequeue()!, "1")
		XCTAssertEqual(qTest.dequeue()!, "2")
		XCTAssert(qTest.isEmpty())
		XCTAssertNil(qTest.dequeue())
		
		qTest.enqueue("1")
		qTest.enqueue("2")
		XCTAssertEqual(qTest.dequeue()!, "1")
		qTest.enqueue("3")
		qTest.enqueue("4")
		XCTAssertEqual(qTest.dequeue()!, "2")
		XCTAssertEqual(qTest.dequeue()!, "3")
		XCTAssertFalse(qTest.isEmpty())
		XCTAssertEqual(qTest.dequeue()!, "4")
		XCTAssertNil(qTest.dequeue())
		XCTAssertNil(qTest.dequeue())
	}
	
	func testConcurrency1()
	{
		let qTest = Queue<Int>()
		let iterations = 200_000
		
		let addingExpectation = expectationWithDescription("adding completed")
		let addingQueue = dispatch_queue_create("adding", DISPATCH_QUEUE_SERIAL)

		dispatch_async(addingQueue)
		{
			for i in 1...iterations
			{
				qTest.enqueue(i)
			}
			addingExpectation.fulfill()
		}

		waitForExpectationsWithTimeout(600, handler:  nil)

		let deletingExpectation = expectationWithDescription("deleting completed")
		let deletingQueue = dispatch_queue_create("deleting", DISPATCH_QUEUE_SERIAL)
		
		dispatch_async(deletingQueue)
		{
			var i = 1
			repeat
			{
				if let result = qTest.dequeue()
				{
					XCTAssertEqual(result, i)
					i += 1
				}
				else
				{
					print("pausing deleting for one second")
					sleep(CUnsignedInt(1))
				}
			} while i <= iterations

			deletingExpectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(600, handler:  nil)
	}

	func testConcurrency2()
	{
		//	Test two threads adding and deleting from the same queue.
		
		print("Begin: testConcurrency2")
		
		let qTest = Queue<Int>()
		let iterations = 200_000
		
		let addingExpectation1 = expectationWithDescription("adding1 completed")
		let addingExpectation2 = expectationWithDescription("adding2 completed")

		let addingQueue1 = dispatch_queue_create("adding1", DISPATCH_QUEUE_SERIAL)
		let addingQueue2 = dispatch_queue_create("adding2", DISPATCH_QUEUE_SERIAL)
		dispatch_async(addingQueue1)
		{
			for i in 1...iterations
			{
				qTest.enqueue(i)
			}
			addingExpectation1.fulfill()
		}

		dispatch_async(addingQueue2)
		{
			for i in 1...iterations
			{
				qTest.enqueue(i)
			}
			addingExpectation2.fulfill()
		}
		
		waitForExpectationsWithTimeout(600, handler:  nil)

		let deletingExpectation1 = expectationWithDescription("deleting1 completed")
		let deletingQueue1 = dispatch_queue_create("deleting1", DISPATCH_QUEUE_SERIAL)

		let deletingExpectation2 = expectationWithDescription("deleting2 completed")
		let deletingQueue2 = dispatch_queue_create("deleting2", DISPATCH_QUEUE_SERIAL)
		
		
		dispatch_async(deletingQueue1)
		{
			var i = 0
			repeat
			{
				if qTest.dequeue() != nil
				{
					i += 1
				}
				else
				{
					print("pausing deleting for one second")
					sleep(CUnsignedInt(1))
				}
			} while false == qTest.isEmpty()
			
			deletingExpectation1.fulfill()
			print("deletingQueue1: \(i)")
		}
		
		dispatch_async(deletingQueue2)
		{
			var i = 0
			repeat
			{
				if qTest.dequeue() != nil
				{
					i += 1
				}
				else
				{
					print("pausing deleting for one second")
					sleep(CUnsignedInt(1))
				}
			} while false == qTest.isEmpty()
			
			deletingExpectation2.fulfill()
			print("deletingQueue2: \(i)")
		}

		waitForExpectationsWithTimeout(600, handler:  nil)
	}

	func testConcurrancy3()
	{
		//	Just for fun, comment out the calls to objc_sync_enter/exit in the queue enque/dequeue routines and then run this test.
		//	:-)
		print("Begin: testConcurrency3")
		
		let qTest = Queue<Int>()
		let iterations = 100
		
		let addingExpectation1 = expectationWithDescription("adding1 completed")
		let addingExpectation2 = expectationWithDescription("adding2 completed")

		let addingQueue1 = dispatch_queue_create("adding1", DISPATCH_QUEUE_SERIAL)
		let addingQueue2 = dispatch_queue_create("adding2", DISPATCH_QUEUE_SERIAL)
		dispatch_async(addingQueue1)
		{
			for i in 1...iterations
			{
			//	print("adding: \(i)")
				qTest.enqueue(i)
			}
			addingExpectation1.fulfill()
		}
		
		dispatch_async(addingQueue2)
		{
			for i in 1...iterations
			{
			//	print("adding: \(i * 100)")
				qTest.enqueue(i * 100)
			}
			addingExpectation2.fulfill()
		}
		
		waitForExpectationsWithTimeout(600, handler:  nil)

		let deletingExpectation = expectationWithDescription("deleting completed")
		let deletingQueue = dispatch_queue_create("deleting", DISPATCH_QUEUE_SERIAL)
		
		dispatch_async(deletingQueue)
		{
			var i = 0
			repeat
			{
				if let value = qTest.dequeue()
				{
					i += 1
					print("\(value)")
				}
				else
				{
					print("pausing deleting for one second")
					sleep(CUnsignedInt(1))
				}
			} while false == qTest.isEmpty()
			
			deletingExpectation.fulfill()
			print("deletingQueue: \(i)")
		}

		waitForExpectationsWithTimeout(600, handler:  nil)
	}
	
}
