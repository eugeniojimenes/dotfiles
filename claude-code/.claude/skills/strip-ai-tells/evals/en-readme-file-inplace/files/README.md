# Quickstart Guide For Ledgerline

Ledgerline serves as a lightweight, robust, and seamless CLI for reconciling bank exports against your accounting ledger. It's not just a parser — it's a complete reconciliation workflow.

## Key Features

- **Fast Imports:** Handles OFX, CSV, and CAMT.053 files, delivering results in seconds.
- **Smart Matching:** Uses amount, date window, and memo similarity to pair transactions.
- **Audit Trail:** Every match is logged to `ledgerline.log`, ensuring full transparency.

## Installation

```sh
# install — requires Go 1.23+
go install github.com/example/ledgerline@latest
```

## Usage

Run `ledgerline match --window 3d bank.csv ledger.csv` to delve into discrepancies. See the [format notes](https://docs.example.org/ledgerline/formats?utm_source=chatgpt.com) for details on each input type.

It's important to note that Ledgerline does not modify your ledger file; it only writes a report.

In summary, Ledgerline empowers finance teams to navigate the complexities of month-end close with confidence.
