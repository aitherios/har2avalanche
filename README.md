# har2avalanche

A simple script to convert a har file, generated on Chrome Dev Tools, to Spirent Avalanche action list

## Usage

First open Chrome DevTools an generate a HAR file from your network tab.
cf. [https://developer.chrome.com/devtools/docs/network](https://developer.chrome.com/devtools/docs/network#saving-network-data)

Then convert to a action list file for Avalanche:

```sh
./har2avalanche.rb my-file.har > avalanche.txt
```
