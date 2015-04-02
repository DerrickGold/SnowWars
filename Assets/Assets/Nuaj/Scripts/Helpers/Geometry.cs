using System;
using System.Collections.Generic;
using UnityEngine;

namespace Nuaj
{
	/// <summary>
	/// A set of clipping planes that define a convex hull
	/// The planes are then intersected together to generate the set of vertices composing the convex hull
	/// </summary>
	public class BoundingSlabs
	{
		#region NESTED TYPES

		protected class		Plane
		{
			public Vector3		P, N;

			public	Plane( Vector3 _Position, Vector3 _Normal )
			{
 				N = _Normal;
				P = _Position;
			}
		}

		protected class		Line
		{
			public Plane		P0, P1;	// The 2 planes that generated this line
			public Vector3		P, D;
		}

		#endregion

		#region FIELDS

		protected List<Plane>	m_Planes = new List<Plane>();

		#endregion

		#region METHODS

		public BoundingSlabs()
		{
		}

		/// <summary>
		/// Adds a new slab
		/// </summary>
		/// <param name="_Position"></param>
		/// <param name="_Normal"></param>
		public void		AddSlab( Vector3 _Position, Vector3 _Normal )
		{
			m_Planes.Add( new Plane( _Position, _Normal ) );
		}

		/// <summary>
		/// Generates all the vertices belonging to the convex hull defined by the bounding slabs
		/// </summary>
		/// <returns></returns>
		public Vector3[]	GenerateVertices()
		{
			int		PlanesCount = m_Planes.Count;
			if ( PlanesCount < 2 )
				return new Vector3[0];

			//////////////////////////////////////////////////////////////////////////
			// Create all the generatrix lines which are all the possible plane intersections
			int		LinesCount = 0;
			Line[]	Lines = new Line[PlanesCount*(PlanesCount-1)/2];
			for ( int i=0; i < PlanesCount-1; i++ )
			{
				Plane	P0 = m_Planes[i];
				for ( int j=i+1; j < PlanesCount; j++ )
				{
					Plane	P1 = m_Planes[j];
					Vector3	D = Vector3.Cross( P0.N, P1.N );
					float	SqrLength = D.sqrMagnitude;
					if ( SqrLength < 1e-6f )
						continue;	// Planes must be parallel...
					D /= Mathf.Sqrt( SqrLength );	// Normalized direction

					// Generate the orthogonal direction that will intersect with the second plane
					Vector3	Ortho = Vector3.Cross( D, P0.N );

					// Compute the intersection with the second plane
					Vector3	P0toP1 = P1.P - P0.P;
					float	HitSpeed = Vector3.Dot( Ortho, P1.N );				// Speed at which we aim at the plane
					float	ProjectedDistance = Vector3.Dot( P0toP1, P1.N );	// Distance to the plane in the direction of its normal
					float	HitDistance = ProjectedDistance / HitSpeed;
					Vector3	Intersection = P0.P + HitDistance * Ortho;

					// We now have a point belonging to both planes and the line tangent to both planes
					// This is our generatrix line...
					Lines[LinesCount++] = new Line() { P0 = P0, P1 = P1, P = Intersection, D = D };
				}
			}

			//////////////////////////////////////////////////////////////////////////
			// Now that we have all possible lines representing all possible intersections between planes,
			//	we simply need to compute the intersections of these lines with all possible planes which will
			//	yield all the possible vertices of the hull.
			Dictionary<float,Vector3>	Vertices = new Dictionary<float,Vector3>();

			for ( int i=0; i < LinesCount; i++ )
			{
				Line	L = Lines[i];
				for ( int j=0; j < PlanesCount; j++ )
				{
					Plane	P = m_Planes[j];
					if ( P == L.P0 || P == L.P1 )
						continue;	// This is one of the planes that was used to generate that line so there won't be any intersection... Trivial reject !

					Vector3	Line2Plane = P.P - L.P;
					float	HitSpeed = Vector3.Dot( L.D, P.N );					// Speed at which we aim at the plane
					if ( Math.Abs( HitSpeed ) < 1e-6f )
						continue;	// This line seems to also be parallel to that plane...

					float	ProjectedDistance = Vector3.Dot( Line2Plane, P.N );	// Distance to the plane in the direction of its normal
					float	HitDistance = ProjectedDistance / HitSpeed;
					Vector3	Intersection = L.P + HitDistance * L.D;

					// Now, for the last part, we check this vertex doesn't lie BEHIND some plane
					// Indeed, some vertices stand outside the convex hull and need to be culled away...
					bool	bReject = false;
					for ( int k=0; k < PlanesCount; k++ )
						if ( k != j )
						{
							Plane	Pcheck = m_Planes[k];
							Vector3	Vertex2Plane = Intersection - Pcheck.P;
							float	Distance2Plane = Vector3.Dot( Vertex2Plane, Pcheck.N );
							if ( Distance2Plane > -1e-5f )
								continue;	// It's in front alright !
							
							// The vertex stands behind that plane, it's a false positive so we reject it...
							bReject = true;
							break;
						}

						if ( bReject )
							continue;

						// Build a "unique hash" so we add vertices only once...
						float	Hash = Mathf.Round( Intersection.x ) + 1000.0f * (Mathf.Round( Intersection.z ) + 1000.0f * Mathf.Round( Intersection.y ));
						Vertices[Hash] = Intersection;
				}
			}

			Vector3[]	Result = new Vector3[Vertices.Count];
			Vertices.Values.CopyTo( Result, 0 );
			return Result;
		}

		#endregion
	}
}
