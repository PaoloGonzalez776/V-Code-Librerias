modulo vr.ui {

    // Tipos públicos
    estructura Panel {
        id: u16,
        posicion: Vec3,
        rotacion: Quat,
        tamaño: Vec2
    }

    estructura BotonUI {
        id: u16,
        posicion: Vec2,
        tamaño: Vec2,
        texto: str
    }

    // Estado interno
    estado_interno {
        paneles: HashMap<u16, Panel>,
        botones: HashMap<u16, BotonUI>
    }

    // Inicialización
    func iniciar() {
        // Inicializar el sistema de UI
        kernel_VisorOS.init_ui_system()
    }

    // Funciones de UI
    func crear_panel(posicion: Vec3, rotacion: Quat, tamaño: Vec2) -> Panel {
        let id = kernel_VisorOS.alloc_ui_panel()
        let panel = Panel { id, posicion, rotacion, tamaño }
        estado_interno.paneles.insert(id, panel)
        return panel
    }

    func crear_boton(panel: Panel, posicion: Vec2, tamaño: Vec2, texto: str) -> BotonUI {
        let id = kernel_VisorOS.alloc_ui_button()
        let boton = BotonUI { id, posicion, tamaño, texto }
        estado_interno.botones.insert(id, boton)
        kernel_VisorOS.add_button_to_panel(panel.id, boton)
        return boton
    }

    func actualizar_panel(panel: Panel, nueva_posicion: Vec3, nueva_rotacion: Quat) {
        panel.posicion = nueva_posicion
        panel.rotacion = nueva_rotacion
        kernel_VisorOS.update_panel(panel.id, nueva_posicion, nueva_rotacion)
    }

    func actualizar_boton(boton: BotonUI, nuevo_texto: str) {
        boton.texto = nuevo_texto
        kernel_VisorOS.update_button_text(boton.id, nuevo_texto)
    }
}