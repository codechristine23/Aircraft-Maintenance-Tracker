# Aircraft Maintenance Tracker

A blockchain-based aircraft maintenance tracking system ensuring transparent and immutable maintenance records.

## Overview

This smart contract system enables aircraft owners to register their aircraft, track maintenance activities, and maintain verifiable records of all maintenance work performed.

## Features

- **Aircraft Registration**: Register aircraft with basic information
- **Maintenance Records**: Immutable maintenance history tracking
- **Provider Certification**: Certified maintenance provider system
- **Airworthiness Tracking**: Monitor aircraft airworthiness status
- **Flight Hours Logging**: Track total flight hours for maintenance scheduling

## Contract Functions

### Public Functions

- `register-aircraft`: Register new aircraft in the system
- `certify-maintenance-provider`: Certify maintenance providers (owner only)
- `record-maintenance`: Log maintenance activities
- `update-flight-hours`: Update aircraft flight hours
- `update-airworthiness`: Update airworthiness status

### Read-Only Functions

- `get-aircraft-info`: Retrieve aircraft details
- `get-maintenance-record`: Get specific maintenance record
- `is-maintenance-due`: Check if maintenance is due
- `get-provider-certification`: Check provider certification status

## Usage

1. Register your aircraft using `register-aircraft`
2. Certified providers record maintenance via `record-maintenance`
3. Update flight hours regularly for accurate tracking
4. Monitor maintenance due dates and airworthiness status

## Benefits

- Immutable maintenance history
- Transparent service provider certification
- Automated maintenance scheduling
- Enhanced aviation safety compliance

## License

MIT License