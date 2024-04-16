#if canImport(SFSymbolEnum)

    import SFSymbolEnum

    public extension SFSymbol {
        /// Finds the most similar symbol to a given input string.
        /// This method searches through all `SFSymbol` cases to find the symbol
        /// whose name has the minimum Levenshtein distance to the input string.
        ///
        /// - Parameter input: A string to compare against symbol names.
        /// - Returns: The `SFSymbol` that is most similar to the provided input string.
        ///            Returns `nil` if there are no symbols (unlikely in practical scenarios).
        static func findSymbol(by input: String) -> SFSymbol? {
            let allSymbols = SFSymbol.allCases
            var minimumDistance = Int.max
            var mostSimilarSymbol: SFSymbol?

            for symbol in allSymbols {
                let distance = SFSymbol.levenshteinDistance(from: symbol.name, to: input)
                if distance < minimumDistance {
                    minimumDistance = distance
                    mostSimilarSymbol = symbol
                }
            }
            return mostSimilarSymbol
        }

        /// ## Levenshtein Distance Algorithm
        /// *Descriprion:*  Calculates the Levenshtein distance between two strings.
        /// The Levenshtein distance is a string metric for measuring the difference between two sequences.
        /// It is calculated as the minimum number of single-character edits (insertions, deletions, or substitutions)
        /// required to change one string into the other.
        /// - Note: Matrix Initialization: A matrix of size (len1+1) x (len2+1) is created, where len1 and len2 are the lengths of s1 and s2, respectively. This matrix is used to store the distance calculations.
        ///        Base Cases: The first row and the first column of the matrix are filled with indices (0 to len1 and 0 to len2). These represent the number of operations required to convert the string to or from an empty string.
        ///        Dynamic Calculation: For each character in s1 and s2, calculate the cost of deletion, insertion, or substitution. The value at matrix[i][j] is set to the minimum cost among these three operations.
        ///        Retrieve Result: The value at matrix[len1][len2] gives the Levenshtein distance between s1 and s2.
        ///        This implementation efficiently calculates the distance and integrates well within your method to find the most similar SFSymbol based on a given string input.
        /// - Parameters:
        ///   - s1: The first string.
        ///   - s2: The second string.
        /// - Returns: The Levenshtein distance as an integer.
        ///
        ///
        private static func levenshteinDistance(from s1: String, to s2: String) -> Int {
            let (len1, len2) = (s1.count, s2.count)
            var matrix = Array(repeating: Array(repeating: 0, count: len2 + 1), count: len1 + 1)

            for i in 0 ... len1 {
                matrix[i][0] = i
            }

            for j in 0 ... len2 {
                matrix[0][j] = j
            }

            for i in 1 ... len1 {
                for j in 1 ... len2 {
                    if s1[s1.index(s1.startIndex, offsetBy: i - 1)] == s2[s2.index(s2.startIndex, offsetBy: j - 1)] {
                        matrix[i][j] = matrix[i - 1][j - 1] // no operation needed
                    } else {
                        matrix[i][j] = min(
                            matrix[i - 1][j] + 1, // deletion
                            matrix[i][j - 1] + 1, // insertion
                            matrix[i - 1][j - 1] + 1 // substitution
                        )
                    }
                }
            }
            return matrix[len1][len2]
        }
    }

#endif
