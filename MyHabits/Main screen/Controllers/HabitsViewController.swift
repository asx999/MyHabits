//
//  HabitsViewController.swift
//  MyHabits
//
//  Created by Александр on 03.03.2023.
//

import UIKit

final class HabitsViewController: UIViewController {

    //MARK: - Add BarButton
    private lazy var barButton: UIBarButtonItem = {
        var button = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(actionBarButton))
        button.tintColor = colorStyle(style: .magenta)
        return button
    }()

    //MARK: - Add CollectionView
    private lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        var view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = colorStyle(style: .white)
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(ProgressCollectionViewCell.self, forCellWithReuseIdentifier: ProgressCollectionViewCell.reuseId)
        view.register(HabitCollectionViewCell.self, forCellWithReuseIdentifier: HabitCollectionViewCell.reuseId)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = habitsViewControllerTitle
        navigationController?.navigationBar.tintColor = colorStyle(style: .magenta)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationItem.rightBarButtonItem = barButton
    }

    //MARK: - SetupLayout
    private func setupLayout() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    //MARK: - ActionBarButton
    @objc private func actionBarButton() {
        let habitViewController = HabitViewController(data: HabitModel())
        habitViewController.thisDelegate = self
        let habitNavigationViewController = UINavigationController(rootViewController: habitViewController)
        navigationController?.present(habitNavigationViewController, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDataSource
extension HabitsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : HabitsStore.shared.habits.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCollectionViewCell.reuseId, for: indexPath)
            if let editCell = cell as? ProgressCollectionViewCell {
                editCell.updateCell(object: HabitsStore.shared.todayProgress)
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabitCollectionViewCell.reuseId, for: indexPath)
            if let editCell = cell as? HabitCollectionViewCell {
                editCell.thisDelegate = self
                let habit = HabitsStore.shared.habits[indexPath.item]
                editCell.updateCell(object: HabitModel(id: indexPath.item, name: habit.name, date: habit.date, color: habit.color))
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let habit = HabitsStore.shared.habits[indexPath.item]
            let habitDetails = HabitDetailsViewController(data: HabitModel(id: indexPath.item, name: habit.name, date: habit.date, color: habit.color))
            habitDetails.thisDelegate = self
            navigationController?.pushViewController(habitDetails, animated: true)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension HabitsViewController: UICollectionViewDelegateFlowLayout {

    private func widthForSection(collectionViewWidth: CGFloat, numberOfItems: CGFloat, indent: CGFloat) -> CGFloat {
        return (collectionViewWidth - indent * (numberOfItems + 1)) / numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = widthForSection(collectionViewWidth: collectionView.frame.width, numberOfItems: 1, indent: 16)
        return indexPath.section == 0 ? CGSize(width: width, height: 60) : CGSize(width: width, height: 130)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return section == 0 ? 18 : 12 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { return section == 0 ? UIEdgeInsets(top: 22, left: 16, bottom: 0, right: 16) : UIEdgeInsets(top: 18, left: 16, bottom: 22, right: 16)
    }
}

//MARK: - HabitDelegate
extension HabitsViewController: HabitDelegate {

    func updateData() {
        collectionView.reloadData()
    }

    func presentController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    func dismissController(animated: Bool, completion: (() -> Void)?) {
        self.dismiss(animated: animated, completion: completion)
    }
}
