0.8.1
-----------
 - Ruby 2.4 support added

0.8.0
-----------
 - Add Time filter: ```time :start_time```
 - Remove unprintable characters from `string` by default.
 - Add bigdecimal and float as non-strict string input options
 - Additonal filters that are used in arrays can now have block arguments
 - Add `empty_is_nil` option to integer filter.

0.7.2
-----------

- Bug fix: discards_empty broke on non-strings. Fix that.

0.7.1
-----------

- Bug fix: If your optional filter discards_empty and strips, then discard whitespace.

0.7.0
-----------

- Ruby 2.1 support added.
- Ruby 1.8.7 support removed.
- Rubinius support updated.
- Gemfile.lock removed (Rails 4 support, etc)
- API change: Add ability to implement a 'validate' method
- ```discard_invalid``` option added
- AdditionFilters: Gain ability to pass blocks to filters.

0.6.0
-----------

- Add pluggable filters.
- Add ruby 1.8.7 support [#19]
- Add a date filter: ```date :start_date``` (/via @eliank and @geronimo)
- ```Mutations.cache_constants = false``` if you want to work in Rails dev mode which redefines constants. [#23]

0.5.12
-----------

- Added a duck filter: ```duck :lengthy, methods: :length``` to ensure all values respond_to? :length [#14]
- Added a file filter: ```file :data``` to ensure the data is a File-like object [#15]
- Allow raw_inputs to be used as method inside of execute to access the original data passed in. (@tomtaylor)
- integer filter now allows the ```in``` option. Eg: ```integer :http_code, in: (200, 404, 401)```   (/via @tomtaylor)
- Added a changelog. [#10]

0.5.11
-----------

- Float filter (@aq1018)
- Clean up public API + code (@blambeau)
- Model filters should lazily resolve their classes so that mocks can be used (@edwinv)
- Filtered inputs should be included in the Outcome
- Fix typos (@frodsan)

0.5.10 and earlier
-----------

- Initial versions
