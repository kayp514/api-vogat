import { NextResponse } from 'next/server';
import { updateDomainSwitchStatus, getDomain } from '@/lib/db-pbx/queries';

type SwitchStatus = "pending" | "provisioning" | "provisioned" | "failed"

const VALID_STATUSES: SwitchStatus[] = ['pending', 'provisioning', 'provisioned', 'failed'];

/**
 * PATCH /api/v1/domains/:domainId
 * Update domain provisioning status
 * Called by Cloud Run after receiving Pub/Sub message with { domainId, slug, tenantId }
 */
export async function PATCH(
    request: Request,
    { params }: { params: Promise<{ domainId: string }> }
) {
    try {
        const { domainId } = await params;
        const body = await request.json();
        const { homeSwitch, switchStatus, ipAddress } = body;

        if (!switchStatus || !VALID_STATUSES.includes(switchStatus)) {
            return NextResponse.json(
                { success: false, error: 'Invalid or missing switchStatus' },
                { status: 400 }
            );
        }

        const updatedDomain = await updateDomainSwitchStatus(domainId, {
            switchStatus,
            homeSwitch,
            ipAddress,
        });

        return NextResponse.json({ success: true, data: updatedDomain });
    } catch (error) {
        if ((error as { code?: string }).code === 'P2025') {
            return NextResponse.json(
                { success: false, error: 'Domain not found' },
                { status: 404 }
            );
        }

        console.error('Error updating domain:', error);
        return NextResponse.json(
            { success: false, error: 'Internal server error' },
            { status: 500 }
        );
    }
}

/**
 * GET /api/v1/domains/:domainId
 * Get domain provisioning status
 */
export async function GET(
    request: Request,
    { params }: { params: Promise<{ domainId: string }> }
) {
    try {
        const { domainId } = await params;

        const domain = await getDomain(domainId);

        if (!domain) {
            return NextResponse.json(
                { success: false, error: 'Domain not found' },
                { status: 404 }
            );
        }

        return NextResponse.json({
            success: true,
            data: {
                id: domain.id,
                name: domain.name,
                homeSwitch: domain.homeSwitch,
                switchStatus: domain.switchStatus,
                ipAddress: domain.ipAddress,
            }
        });
    } catch (error) {
        console.error('Error fetching domain:', error);
        return NextResponse.json(
            { success: false, error: 'Internal server error' },
            { status: 500 }
        );
    }
}
