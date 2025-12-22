modulo vr.ui.interactive {

    // Tipos públicos
    estructura BotonInteractivo {
        id: u16,
        posicion: Vec2,
        tamaño: Vec2,
        texto: str,
        evento_click: func()
    }

    estructura PanelInteractivo {
        id: u16,
        posicion: Vec3,
        rotacion: Quat,
        tamaño: Vec2,
        botones: [BotonInteractivo]
    }

    // Estado interno
    estado_interno {
        paneles: HashMap<u16, PanelInteractivo>
    }

    // Inicialización
    func iniciar() {
        estado_interno.paneles = crear_hashmap()
    }

    // Funciones de UI interactiva
    func crear_panel_interactivo(posicion: Vec3, rotacion: Quat, tamaño: Vec2) -> PanelInteractivo {
        let id = generar_id()
        let panel = PanelInteractivo { id, posicion, rotacion, tamaño, botones: [] }
        estado_interno.paneles.insert(id, panel)
        return panel
    }

    func agregar_boton(panel: PanelInteractivo, posicion: Vec2, tamaño: Vec2, texto: str, evento_click: func()) {
        let id = generar_id()
        let boton = BotonInteractivo { id, posicion, tamaño, texto, evento_click }
        panel.botones.push(boton)
    }

    func actualizar_panel(panel: PanelInteractivo, nueva_posicion: Vec3, nueva_rotacion: Quat) {
        panel.posicion = nueva_posicion
        panel.rotacion = nueva_rotacion
        kernel_VisorOS.update_interactive_panel(panel.id, nueva_posicion, nueva_rotacion)
    }

    // Funciones de ayuda
    func generar_id() -> u16 {
        return kernel_VisorOS.generate_unique_id()
    }
}