# 30-07-2025

## Problem

When `phdwebsite.duckdns.org` domain points to an IP that does not forward requests (CG-NAT in my case), requests are not resolved for a long time. Problem with no-resolving requests was caused by no timeouts configured on the http client.

## Solution

Since `Client` from `http` package does not support configuring timeouts, I created a decorator that applies the same timeout for all requests and returnes `408` status code when timeout occurrs (in methos where it made sens).
