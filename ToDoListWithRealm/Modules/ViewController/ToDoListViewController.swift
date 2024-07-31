//
//  ToDoListViewController.swift
//  ToDoListWithRealm
//
//  Created by Erma on 31/7/24.
//

import UIKit
import Combine
import RealmSwift

class ToDoListViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        return tableView
    }()
    
    var viewModel = ToDoListViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupConstraints()
        setupNavigationItem()
        bindViewModel()
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ToDoListCell.self, forCellReuseIdentifier: ToDoListCell.reusd)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "ToDoList"
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didPlusButtonTapped))
        rightBarButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightBarButtonItem
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(didTrashButtonTapped))
        leftBarButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func bindViewModel() {
        viewModel.$tasks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func didPlusButtonTapped() {
        let alert = UIAlertController(title: "Новая задача", message: "Пожалуйста,заполните поле.", preferredStyle: .alert)
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая задача"
        }
        let action = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self, let text = alertTextField.text, !text.isEmpty else { return }
            let task = Tasks()
            task.task = text
            do {
                try self.viewModel.addTask(task)
            } catch {
                print("Ошибка при добавлении задачи: \(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    @objc private func didTrashButtonTapped() {
        let alert = UIAlertController(title: "Delete all tasks", message: "Are you sure?", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Delete", style: .destructive){ [weak self]  _ in
            guard let self else { return }
            do {
                try self.viewModel.deleteAllTasks()
            } catch {
                print("Ошибка при удалении всех задач: \(error)")
            }
            
        }
        let acceptDecline = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(acceptDecline)
        alert.addAction(acceptAction)
        
        present(alert, animated: true)
    }
}

extension ToDoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListCell.reusd, for: indexPath) as! ToDoListCell
        if let task = viewModel.tasks?[indexPath.row] {
            cell.fill(with: task.task)
        }
        return cell
    }
}

extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let task = viewModel.tasks?[indexPath.row] else { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self  else { return }
            do {
                try self.viewModel.deleteTask(task)
                completionHandler(true)
            } catch {
                print("Ошибка при удалении задачи: \(error)")
                completionHandler(false)
            }
        }
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}





