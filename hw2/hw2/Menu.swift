//
//  Menu.swift
//  hw2
//
//  Created by Никита on 25.04.2021.
//
import Foundation

class Menu <T:Equatable>{
	
	var check = true
	var threadSafeArray: [T] = []
	private let queue = DispatchQueue(label: "SafeArray", attributes: .concurrent)
	
	func start() {
		print("-----")
		print("Меню: ")
		print("1 - Вывод массива")
		print("2 - Добавить элемент в массив")
		print("3 - Удалить элемент в массиве ")
		print("4 - Элемент массива с указанным индеком")
		print("5 - Проверка наличия элемента в коллекции")
		print("6 - Очистить массив")
		print("0 - Exit")
		print("-----")
		
		while check {
			if let manuItem = Int(strongReadLine("Выберите пункт меню ")) {
				switch manuItem {
				case 1:
					printAllCars()
				case 2:
					append(newElement: input("Введите новый элемент"))
				case 3:
					if let index = Int(strongReadLine("Введите индекс")) {
						removeAtIndex(index: index-1)
					}
				case 4:
					if let index = Int(strongReadLine("Введите индекс")) {
						print(threadSafeArray[index-1])
					}
				case 5:
					if !contains(input("Введите элемент")){
						print("Такого элемента нет")
					} else {
						print("Элемент существует")
					}
				case 6:
					threadSafeArray = []
				case 0:
					print("Пока.")
					check = false
					return
				default:
					print("Неверный пункт меню")
				}
			} else {
				print("Ошибка ввода данных")
			}
			self.start()
		}
	}
	// MARK: Ввод элементов
	func input (_ text: String) -> T {
		print(text)
		
		if let symbol = readLine() as? T {
			return symbol
		} else {
			return input("Введите еще раз")
		}
		
	}
	
	// MARK: Проверка элемента на наличе в массиве
	func contains(where predicate: (T) -> Bool) -> Bool {
		var result = false
		queue.sync { result = self.threadSafeArray.contains(where: predicate) }
		return result
	}
	// MARK: Корректный подсчет длины массива
	public var count: Int {
		var count = 0
		
		self.queue.sync {
			count = self.threadSafeArray.count
		}
		return count
	}
	// MARK: Проверка на пустой массив
	var isEmpty: Bool {
		var result = false
		queue.sync { result = self.threadSafeArray.isEmpty }
		return result
	}
	
	// MARK: - Проверка массива
	func testArray () {
		print("Колличесвто элементов массива")
		let value : T?
		value = 1 as? T
		if let a = value {
			DispatchQueue.global(qos: .userInteractive).async {
				for _ in 0...1000 {
					self.append(newElement: a)
					
				}
			}
			DispatchQueue.global(qos: .userInteractive).async {
				for _ in 0...1000 {
					self.append(newElement: a )
					
				}
			}
		}
		sleep(1)
		print(count)
	}
	// MARK: - Удаления элмента в массиве
	public func removeAtIndex(index: Int) {
		
		self.queue.async(flags:.barrier) {
			self.threadSafeArray.remove(at: index)
		}
	}
	// MARK: - subscript
	public subscript(index: Int) -> T {
		set {
			self.queue.async(flags:.barrier) {
				self.threadSafeArray[index] = newValue
			}
		}
		get {
			var element: T!
			self.queue.sync {
				element = self.threadSafeArray[index]
			}
			
			return element
		}
	}
	
	// MARK: - Добавления элмента в массив
	public func append(newElement: T) {
		self.queue.async(flags:.barrier) {
			self.threadSafeArray.append(newElement)
		}
	}
	
	
	// MARK: - Вывод массива
	func printAllCars() {
		print("-----")
		print("Массив:")
		if !isEmpty{
			self.threadSafeArray.forEach { a in
				print(a)
			}
		} else {
			print("массив пустой")
		}
	}
	
	// MARK: -  Орбработка ввода
	
	func strongReadLine(_ text: String) -> String {
		print(text)
		let numCharacters = "0123456789"
		
		if let input = readLine() {
			if !input.isEmpty {
				guard numCharacters.contains(input)  else {
					print("Ошибка ввода данных")
					return self.strongReadLine(text)
				}
			}
			return  input
		}
		print("Ошибка ввода данных")
		return self.strongReadLine(text)
	}
	
}

// MARK: -  protocol Equatable

extension Menu where T: Equatable {
	
	func contains(_ element: T) -> Bool {
		var result = false
		queue.sync { result = self.threadSafeArray.contains(element) }
		return result
	}
}
