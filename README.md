> This project is currently under develpoment and not yet feature complete


# Chassis

The missing iOS project template.

## Features (WIP):

- To be used as a template when starting a new iOS project
- Provides a template for all architectural components of an app
- minimal showcase UI
- CRUD
- Uses latest Apple tech as of writing (DiffableDataSource, @main)
- does _not_ use SwiftUI



### AppModules

`UIResponder` subclasses that are appended to the responder chain after `AppDelegate`.



## Design paradigms:

The usual suspects:    
- KISS
- DRY

But some more:   
- no external dependencies
- decouble everything
- use DI
- no singletons (ideally)
- use first responder proxy for all actions
- separate generic code from domain related code (data model & business logic)



## Contribution:  

This project is currently under development and we don't take pull requests yet. 
