## Problem

I had to choose the algorithm used for parsing version number sent
by the frontend. I created two implementations:

- **manual parser** - uses a simple loop to go through the version string and parses it as it goes.
- **regex parser** - uses a regex with capturing groups

## Validation

I created a JMH benchmark that tested both implementation performance. The results are in the table below.

| Benchmark                                                    | Mode | Cnt | Score | Error | Units |
|--------------------------------------------------------------|------|-----|-------|-------|-------|
| AppVersionParsersBenchmark.benchmarkParsingUsingManualParser | avgt | 5   | 0.149 | 0.001 | us/op |
| AppVersionParsersBenchmark.benchmarkParsingUsingRegexParser  | avgt | 5   | 0.328 | 0.004 | us/op |

## Conclusion

Manual mapper turned out to be ~2.2 times as fast as the regex-backed implementation. It will be used in runtime
to parse version string.