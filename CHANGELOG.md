unreleased
-----------

- Add ruby 1.8.7 support [#19]
- Add a date filter: ```date :start_date``` (/via @eliank and @geronimo)

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
