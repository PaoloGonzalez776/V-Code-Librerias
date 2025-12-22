modulo vr.utils {

    // Funciones matemáticas
    func distancia(a: Vec3, b: Vec3) -> f32 {
        return (b - a).magnitude()
    }

    func angulo_entre(a: Vec3, b: Vec3) -> f32 {
        return a.angle_to(b)
    }

    // Funciones de memoria
    func reservar_pila(tamaño: usize) -> *mut u8 {
        return kernel_VisorOS.alloc_stack(tamaño)
    }

    func liberar_pila(puntero: *mut u8) {
        kernel_VisorOS.free_stack(puntero)
    }

    // Funciones de tiempo
    func tiempo_actual() -> milisegundos {
        return kernel_VisorOS.get_current_time()
    }

    func esperar(tiempo: milisegundos) {
        kernel_VisorOS.sleep(tiempo)
    }
}