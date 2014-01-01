/////////////////////////////////////////////////////////////////////////////////
//
// Thor C++ Library
// Copyright (c) 2011-2014 Jan Haller
// 
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
// 
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 
// 3. This notice may not be removed or altered from any source distribution.
//
/////////////////////////////////////////////////////////////////////////////////

#include <Thor/Particles/Emitters.hpp>
#include <Thor/Particles/EmissionInterface.hpp>
#include <Thor/Particles/Particle.hpp>


namespace thor
{

UniversalEmitter::UniversalEmitter()
: mEmissionRate(1.f)
, mEmissionDifference(0.f)
, mParticleLifetime(sf::seconds(1.f)) 
, mParticlePosition(sf::Vector2f(0.f, 0.f))
, mParticleVelocity(sf::Vector2f(0.f, 0.f))
, mParticleRotation(0.f)
, mParticleRotationSpeed(0.f)
, mParticleScale(sf::Vector2f(1.f, 1.f))
, mParticleColor(sf::Color::White)
, mParticleTextureIndex(0u)
{
}

void UniversalEmitter::operator() (EmissionInterface& system, sf::Time dt)
{
	const unsigned int nbParticles = computeParticleCount(dt);

	for (unsigned int i = 0; i < nbParticles; ++i)
	{
		// Create particle and specify parameters
		Particle particle( mParticleLifetime() );
		particle.position = mParticlePosition();
		particle.velocity = mParticleVelocity();
		particle.rotation = mParticleRotation();
		particle.rotationSpeed = mParticleRotationSpeed();
		particle.scale = mParticleScale();
		particle.color = mParticleColor();
		particle.textureIndex = mParticleTextureIndex();

		system.emitParticle(particle);
	}
}

void UniversalEmitter::setEmissionRate(float particlesPerSecond)
{
	mEmissionRate = particlesPerSecond;
}

void UniversalEmitter::setParticleLifetime(Distribution<sf::Time> particleLifetime)
{
	mParticleLifetime.swap(particleLifetime);
}

void UniversalEmitter::setParticlePosition(Distribution<sf::Vector2f> particlePosition)
{
	mParticlePosition.swap(particlePosition);
}

void UniversalEmitter::setParticleVelocity(Distribution<sf::Vector2f> particleVelocity)
{
	mParticleVelocity.swap(particleVelocity);
}

void UniversalEmitter::setParticleRotation(Distribution<float> particleRotation)
{
	mParticleRotation.swap(particleRotation);
}

void UniversalEmitter::setParticleRotationSpeed(Distribution<float> particleRotationSpeed)
{
	mParticleRotationSpeed.swap(particleRotationSpeed);
}

void UniversalEmitter::setParticleScale(Distribution<sf::Vector2f> particleScale)
{
	mParticleScale.swap(particleScale);
}

void UniversalEmitter::setParticleColor(Distribution<sf::Color> particleColor)
{
	mParticleColor.swap(particleColor);
}

void UniversalEmitter::setParticleTextureIndex(Distribution<unsigned int> particleTextureIndex)
{
	mParticleTextureIndex.swap(particleTextureIndex);
}

unsigned int UniversalEmitter::computeParticleCount(sf::Time dt)
{
	// We want to fulfill the desired particle rate as exact as possible. Since the amount of emitted particles per frame is
	// integral, we have to emit sometimes more and sometimes less. mParticleDifference takes care of the deviation each frame.
	float particleAmount = mEmissionRate * dt.asSeconds() + mEmissionDifference;
	unsigned int nbParticles = static_cast<unsigned int>(particleAmount);

	// Compute difference for next frame, return current amount
	mEmissionDifference = particleAmount - nbParticles;
	return nbParticles;
}

} // namespace thor
