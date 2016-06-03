//
//  Queue.swift
//
//  Created by Allan Hoeltje on 5/7/16.
//  Copyright © 2016 Allan Hoeltje. All rights reserved.
//
//	See:
//		https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics)

import Foundation

private class QueueItem<T>
{
	let value: T!
	var next: QueueItem?
	
	init(_ newvalue: T?)
	{
		self.value = newvalue
	}
}

///	A simple first-in-first-out queue
///	Supports simultaneous adding and removing.
public class Queue<T>
{
	typealias Element = T
	
	private var frontItem:	QueueItem<Element>
	private var backItem:	QueueItem<Element>
	private var lock:		AnyObject
	
	public init()
	{
		// Insert dummy item. Will disappear when the first item is added.
		backItem	= QueueItem(nil)
		frontItem	= backItem			//	Note that frontItem is always a reference
		lock		= Int(0)
	}
	
	/// Add a new item to the back of the queue.
	public func enqueue(value: T)
	{
		if OBJC_SYNC_SUCCESS == Int(objc_sync_enter(lock))
		{
			backItem.next	= QueueItem(value)
			backItem		= backItem.next!

			objc_sync_exit(lock)
		}
	}
	
	/// Return and remove the item at the front of the queue.
	public func dequeue() -> T?
	{
		var item: T?
		
		if OBJC_SYNC_SUCCESS == Int(objc_sync_enter(lock))
		{
			if let newhead = frontItem.next
			{
				frontItem = newhead		//	ARC will release the old frontItem
				item = newhead.value
			}

			objc_sync_exit(lock)
		}
		
		return item
	}
	
	public func isEmpty() -> Bool
	{
		var empty = false
		
		//	Note that this must be sync'd because some other thread could be changing the front or back
		if OBJC_SYNC_SUCCESS == Int(objc_sync_enter(lock))
		{
			empty = (frontItem === backItem)
			
			objc_sync_exit(lock)
		}
		
		return empty
	}
}
