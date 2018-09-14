//
//  Copyright © 2018 Webbhälsa AB. All rights reserved.
//

import UIKit

internal enum Different {

    struct Match: Hashable {
        let old: Int
        let new: Int
    }

    internal struct Diff<T: Equatable> {
        internal let deleted: Set<Int>
        internal let inserted: Set<Int>
        internal let updated: Set<Match>

        internal let values: [T]

        internal var isEmpty: Bool {
            return deleted.isEmpty && inserted.isEmpty && updated.isEmpty
        }
    }

    struct MyersDiff {
        internal let deleted: Set<Int>
        internal let inserted: Set<Int>
        internal let lcs: Set<Match>

        internal var isEmpty: Bool {
            return deleted.isEmpty && inserted.isEmpty
        }
    }

    static func diff<T: Equatable, I: Equatable>(between old: [T], and new: [T], matchOn idPath: KeyPath<T, I>) -> Diff<T> {
        let oldIds = old.map { $0[keyPath: idPath] }
        let newIds = new.map { $0[keyPath: idPath] }

        let myers = self.myers(between: oldIds, and: newIds)
        let updated = myers.lcs
            .filter { old[$0.old] != new[$0.new] }

        return Diff(deleted: myers.deleted, inserted: myers.inserted, updated: Set(updated), values: new)
    }

    // Based on http://simplygenius.net/Article/DiffTutorial1
    static func myers<T: Equatable>(between A: [T], and B: [T]) -> MyersDiff {
        let Vs = diffPartial(a: A, b: B)

        var p: (x: Int, y: Int) = (A.count, B.count)

        var deleted: Set<Int> = []
        var inserted: Set<Int> = []
        var lcsMatches: Set<Match> = []

        for d in stride(from: Vs.count - 1, through: 0, by: -1) {
            guard p.x > 0 || p.y > 0 else { break }

            let V = Vs[d]
            let k = p.x - p.y

            let xEnd = V[k]!
            let yEnd = xEnd - k

            let isDown = (k == -d || (k != d && V[k - 1]! < V[k + 1]!))

            let kPrev = isDown ? k + 1 : k - 1

            let xStart = V[kPrev]!
            let yStart = xStart - kPrev

            // mid point
            var xMid = isDown ? xStart : xStart + 1
            var yMid = xMid - k

            while xMid < xEnd && yMid < yEnd {
                lcsMatches.insert(.init(old: xMid, new: yMid))
                xMid += 1
                yMid += 1
            }

            if isDown {
                if yStart >= 0 {
                    inserted.insert(yStart)
                }
            } else {
                if xStart >= 0 {
                    deleted.insert(xStart)
                }
            }

            p.x = xStart
            p.y = yStart
        }

        return MyersDiff(deleted: deleted, inserted: inserted, lcs: lcsMatches)
    }

    private static func diffPartial<T: Equatable>(a A: [T], b B: [T]) -> [[Int: Int]] {
        var Vs: [[Int: Int]] = []
        let N = A.count
        let M = B.count

        var V: [Int: Int] = [1 : 0]

        for d in 0...(N + M) {
            for k in stride(from: -d, through: d, by: 2) {

                let isDown = (k == -d || (k != d && V[k - 1]! < V[k + 1]!))

                let kPrev = isDown ? k + 1 : k - 1
                // start point
                let xStart = V[kPrev]!
                //let yStart = xStart - kPrev

                // mid point
                let xMid = isDown ? xStart : xStart + 1
                let yMid = xMid - k

                // end point
                var xEnd = xMid
                var yEnd = yMid

                // follow diagonal
                var snake = 0
                while (xEnd < N && yEnd < M && A[xEnd] == B[yEnd]) {
                    xEnd += 1
                    yEnd += 1
                    snake += 1
                }

                // save end point
                V[k] = xEnd

                // check for solution
                if (xEnd >= N && yEnd >= M) {
                    Vs.append(V)
                    return Vs
                }
            }

            Vs.append(V)
        }

        return Vs
    }
}


extension Different.Diff {

    internal typealias RowUpdater = (_ cell: UITableViewCell, _ value: T) -> Void

    internal func apply(to tableView: UITableView, inSection section: Int, reconfiguring updater: RowUpdater) {
        guard !isEmpty else {
            return
        }

        guard tableView.indexPathsForVisibleRows?.isEmpty == false else {
            reloadAndFade(in: tableView)
            return
        }

        let deletedIndexPaths = deleted.map { IndexPath(row: $0, section: section) }
        let insertedIndexPaths = inserted.map { IndexPath(row: $0, section: section) }

        runBatchChanges(in: tableView) {
            tableView.deleteRows(at: deletedIndexPaths, with: .automatic)
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)

            updated.forEach { match in
                let oldIndexPath = IndexPath(row: match.old, section: section)
                let newValue = values[match.new]
                guard let visibleCell = tableView.cellForRow(at: oldIndexPath) else {
                    return
                }
                updater(visibleCell, newValue)
            }
        }
    }

    private func reloadAndFade(in tableView: UITableView) {
        let fade = CATransition()
        fade.type = kCATransitionFade
        fade.duration = 0.12
        tableView.layer.add(fade, forKey: "fade")
        tableView.reloadData()
    }

    private func runBatchChanges(in tableView: UITableView, _ changes: () -> Void) {
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates(changes, completion: nil)
        } else {
            tableView.beginUpdates()
            changes()
            tableView.endUpdates()
        }
    }
}
