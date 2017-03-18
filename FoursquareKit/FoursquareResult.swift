//
//  FoursquareResult.swift
//  FoursquareKit
//
//  Created by Adolfo on 18/2/16.
//  Copyright (c) 2016 Desappstre Studio. All rights reserved.
//

import Foundation

/**
	Posibles resultados de obtener el feed
	de información de Foursquare.

	Los posibles valores devolvemos son:

	- Success: Lectura correcta
	- Error: Algo ha fallado en la obtencion del feed
*/
public enum FoursquareResult<T>
{
	/// La operacion ha terminado bien.
	case success(result: T)
	/// Algo ha salido mal.
	/// Devolvemos un mensaje con la descripcion del error
	case error(reason: String)
	/// No hay error pero tampoco datos
	case empty
}