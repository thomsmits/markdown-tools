# Chapter 4: UML embedding

## Approach

Using a self made notation and a corresponding tool, UML diagrams can directly be embedded into the source code.


## Class Diagram

@startuml[80%]
Class { Vogel {abstract}
    +fliegen() {abstract}
}

Class { Ente 
    +fliegen()
    +schwimmen()
    +eierlegen()
}

Class { Flugzeug 
    +fliegen()
}

Class { Wasserflugzeug 
    +fliegen()
    +schwimmen()
}

Interface { Flieger
    +fliegen()
}

Interface { Schwimmer
    +schwimmen()
}

Wasserflugzeug ---!> Flugzeug
Ente ---!> Vogel
Ente ---!> Flieger
Ente ---!> Schwimmer
Flugzeug ---!> Flieger
Wasserflugzeug ---!> Schwimmer
@enduml

