// vr/render/render.vr
// VisorLang SDK – pipeline VR multiview 90-120 FPS
modulo vr.render {

    // ---------- Tipos públicos ----------
    estructura Ojo {
        fov_y:      Radianes,
        aspecto:    f32,
        near:       metros,
        far:        metros,
        res:        (u16, u16),
        cmd_buf:    CmdBuffer,   // handle kernel
    }

    estructura PasosRender {
        sombras:    bool,
        msaa:       u8,           // 1, 2, 4
        varianza:   f32,          // para foveated
    }

    // ---------- Estado interno ----------
    estado_interno {
        ojo_izq:  Ojo,
        ojo_der:  Ojo,
        pipeline: PipelineHandle,
        pasos:    PasosRender = {sombras: true, msaa: 2, varianza: 0.8},
    }

    // ---------- Inicialización ----------
    func iniciar(res_ojo: (u16, u16), fov: Radianes)
        dentro 8milisegundos
        una_sola_vez {

        estado_interno.ojo_izq = crear_ojo(res_ojo, fov, ojo_izquierdo)
        estado_interno.ojo_der = crear_ojo(res_ojo, fov, ojo_derecho)
        estado_interno.pipeline = kernel_VisorOS.create_vr_pipeline()
    }

    // ---------- Getters sin alloc ----------
    func ojo_izquierdo() -> Ojo  sin_alloc { return estado_interno.ojo_izq }
    func ojo_derecho()  -> Ojo  sin_alloc { return estado_interno.ojo_der }

    // ---------- Pipeline completo ----------
    func dibujar_frame(mundo: World)
        dentro 7milisegundos   // presupuesto total fijo
        sin_alloc {

        // 1) Sombras (opcional, 1 ms)
        si estado_interno.pasos.sombras {
            dibujar_sombras(mundo) dentro 1milisegundo
        }

        // 2) Ojo izquierdo (paralelo)
        let cmd_izq = estado_interno.ojo_izq.cmd_buf
        iniciar_registro(cmd_izq)
        dibujar_ojo(mundo, ojo_izquierdo(), cmd_izq) dentro 3milisegundos

        // 3) Ojo derecho (paralelo)
        let cmd_der = estado_interno.ojo_der.cmd_buf
        iniciar_registro(cmd_der)
        dibujar_ojo(mundo, ojo_derecho(), cmd_der) dentro 3milisegundos

        // 4) Submit a GPU (sin copia)
        kernel_VisorOS.submit_eyes(cmd_izq, cmd_der)
    }

    // ---------- Helpers privados ----------
    func crear_ojo(res: (u16, u16), fov: Radianes, lado: Lado) -> Ojo
        dentro 500microsegundos {

        return Ojo {
            fov_y:    fov,
            aspecto:  res.0 / res.1,
            near:     0.1m,
            far:      1000m,
            res:      res,
            cmd_buf:  kernel_VisorOS.alloc_cmd_buffer(res),
        }
    }

    func dibujar_ojo(mundo: World, o: Ojo, cmd: CmdBuffer)
        dentro 3milisegundos {

        // View-Proj matrix
        let view  = calcular_view(o)
        let proj  = calcular_proj(o)
        set_view_proj(cmd, view, proj)

        // Foveated rendering (si varianza < 1)
        si estado_interno.pasos.varianza < 1.0 {
            kernel_VisorOS.set_foveated(cmd, estado_interno.pasos.varianza)
        }

        // Draw calls
        para cada mesh en mundo.meshes {
            dibujar_mesh(cmd, mesh)
        }
    }

    func dibujar_mesh(cmd: CmdBuffer, m: Mesh) {
        // 1 bind, 1 draw-indexed
        kernel_VisorOS.bind_pipeline(cmd, estado_interno.pipeline)
        kernel_VisorOS.bind_vertex_buffer(cmd, m.vb)
        kernel_VisorOS.bind_index_buffer(cmd, m.ib)
        kernel_VisorOS.draw_indexed(cmd, m.index_count)
    }

    // ---------- Ajustes en caliente ----------
    func set_msaa(muestras: u8)  sin_alloc {
        estado_interno.pasos.msaa = muestras
        kernel_VisorOS.update_msaa(estado_interno.pipeline, muestras)
    }

    func set_foveado(factor: f32)  sin_alloc {
        estado_interno.pasos.varianza = clamp(factor, 0.5, 1.0)
    }
}