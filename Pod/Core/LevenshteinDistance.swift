// https://en.wikipedia.org/wiki/Levenshtein_distance#Iterative_with_two_matrix_rows
extension String {

    subscript(_ i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }

    func levenshteinDistance(_ target: String) -> Int {
        // create two work vectors of integer distances
        var last, current: [Int]

        // initialize v0 (the previous row of distances)
        // this row is A[0][i]: edit distance for an empty s
        // the distance is just the number of characters to delete from t
        last = [Int](0...target.count)
        current = [Int](repeating: 0, count: target.count + 1)

        for i in 0..<self.count {
            // calculate v1 (current row distances) from the previous row v0

            // first element of v1 is A[i+1][0]
            //   edit distance is delete (i+1) chars from s to match empty t
            current[0] = i + 1

            // use formula to fill in the rest of the row
            for j in 0..<target.count {
                current[j+1] = Swift.min(
                    last[j+1] + 1,
                    current[j] + 1,
                    last[j] + (self[i] == target[j] ? 0 : 1)
                )
            }

            // copy v1 (current row) to v0 (previous row) for next iteration
            last = current
        }

        return current[target.count]
    }

}

extension GherkinState {
    func suggestedSteps(forStep expression: String) -> [Step] {
        let stepsWithDistance = steps.sorted(by: { $0.expression < $1.expression })
            .map({
                (step: $0, distance: $0.expression.levenshteinDistance(expression))
            })
            // do not suggest steps which expressions are shorter than the distance
            .filter({ $0.step.expression.count > $0.distance })

        guard let minDistance = stepsWithDistance.min(by: { $0.distance < $1.distance })?.distance else {
            return []
        }

        // suggest all steps with the same distance
        let suggestedSteps = stepsWithDistance.filter({ $0.distance == minDistance })
        return suggestedSteps.map({ $0.step })
    }
}
