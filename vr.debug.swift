modulo vr.debug {

    // Tipos públicos
    estructura MensajeDepuracion {
        nivel: NivelDepuracion,
        mensaje: str
    }

    enumeracion NivelDepuracion {
        Informacion,
        Advertencia,
        Error
    }

    // Funciones de depuración
    func imprimir(mensaje: str) {
        kernel_VisorOS.print_message(mensaje)
    }

    func imprimir_error(mensaje: str) {
        let mensaje_error = MensajeDepuracion { nivel: NivelDepuracion.Error, mensaje }
        kernel_VisorOS.print_debug_message(mensaje_error)
    }

    func imprimir_advertencia(mensaje: str) {
        let mensaje_advertencia = MensajeDepuracion { nivel: NivelDepuracion.Advertencia, mensaje }
        kernel_VisorOS.print_debug_message(mensaje_advertencia)
    }

    func imprimir_informacion(mensaje: str) {
        let mensaje_informacion = MensajeDepuracion { nivel: NivelDepuracion.Informacion, mensaje }
        kernel_VisorOS.print_debug_message(mensaje_informacion)
    }

    // Funciones de perfilado
    func iniciar_perfilado() {
        kernel_VisorOS.start_profiling()
    }

    func detener_perfilado() {
        kernel_VisorOS.stop_profiling()
    }

    func obtener_perfilado() -> str {
        return kernel_VisorOS.get_profiling_data()
    }
}